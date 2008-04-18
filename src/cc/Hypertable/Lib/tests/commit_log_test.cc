/** -*- c++ -*-
 * Copyright (C) 2008 Doug Judd (Zvents, Inc.)
 * 
 * This file is part of Hypertable.
 * 
 * Hypertable is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; version 2 of the
 * License.
 * 
 * Hypertable is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301, USA.
 */

#include <cassert>
#include <cstdlib>

#include "AsyncComm/Comm.h"

#include "Common/Properties.h"
#include "Common/Logger.h"
#include "Common/System.h"
#include "Common/String.h"
#include "Common/Usage.h"

#include "Hypertable/Lib/Defaults.h"
#include "Hypertable/Lib/CommitLog.h"
#include "Hypertable/Lib/CommitLogReader.h"

#include "DfsBroker/Lib/Client.h"


using namespace Hypertable;

namespace {
  const char *usage[] = {
    "usage: commit_log_test",
    "",
    "Tests the commit log.",
    "",
    0
  };

  void test1(DfsBroker::Client *dfs_client);
  void write_entries(CommitLog *log, int num_entries, uint64_t *sump);
  void read_entries(CommitLogReader *log_reader, uint64_t *sump);
}



int main(int argc, char **argv) {
  CommPtr comm_ptr;
  ConnectionManagerPtr conn_manager_ptr;
  DfsBroker::Client *dfs_client;

  if (argc == 2 && !strcmp(argv[1], "--help"))
    Usage::dump_and_exit(usage);

  try {

    System::initialize(argv[0]);
    ReactorFactory::initialize( System::get_processor_count() );

    comm_ptr = new Comm();
    conn_manager_ptr = new ConnectionManager(comm_ptr.get());

    /**
     * connect to DFS broker
     */
    {
      struct sockaddr_in addr;
      InetAddr::initialize(&addr, "localhost", HYPERTABLE_RANGESERVER_COMMITLOG_DFSBROKER_PORT);
      dfs_client = new DfsBroker::Client(conn_manager_ptr, addr, 60);
      if (!dfs_client->wait_for_connection(10)) {
	HT_ERROR("Unable to connect to DFS Broker, exiting...");
	exit(1);
      }
    }

    srandom(1);

    test1(dfs_client);

  }
  catch (Hypertable::Exception &e) {
    HT_ERRORF("%s - %s", e.what(), Error::get_text(e.code()));
    ReactorFactory::destroy();
    return 1;
  }

  ReactorFactory::destroy();
  return 0;
}



namespace {

  void test1(DfsBroker::Client *dfs_client) {
    PropertiesPtr props_ptr = new Properties();
    String log_dir = "/hypertable/test_log";
    String fname;
    CommitLog *log;
    CommitLogReader *log_reader;
    uint64_t sum_written = 0;
    uint64_t sum_read = 0;

    // Remove /hypertable/test_log
    dfs_client->rmdir(log_dir);

    fname = log_dir + "/c";

    // Create /hypertable/test_log/c
    dfs_client->mkdirs(fname);

    props_ptr->set("Hypertable.RangeServer.CommitLog.RollLimit", "2000");

    log = new CommitLog(dfs_client, fname, props_ptr);

    write_entries(log, 20, &sum_written);

    log->close();

    delete log;

    log_reader = new CommitLogReader(dfs_client, fname);

    read_entries(log_reader, &sum_read);

    delete log_reader;

    HT_EXPECT(sum_read == sum_written, Error::FAILED_EXPECTATION);
  }

  void write_entries(CommitLog *log, int num_entries, uint64_t *sump){
    int error;
    uint64_t timestamp;
    uint32_t limit;
    uint32_t payload[101];

    for (size_t i=0; i<50; i++) {
      timestamp = log->get_timestamp();

      limit = (random() % 100) + 1;
      for (size_t j=0; j<limit; j++) {
	payload[j] = random();
	*sump += payload[j];
      }

      if ((error = log->write((uint8_t *)payload, (uint32_t)4*limit, timestamp)) != Error::OK)
	throw Hypertable::Exception(error, "Problem writing to log file");
    }
  }

  void read_entries(CommitLogReader *log_reader, uint64_t *sump) {
    const uint8_t *block;
    size_t block_len;
    uint32_t *iptr;
    size_t icount;
    BlockCompressionHeaderCommitLog header;

    while (log_reader->next_block(&block, &block_len, &header)) {
      assert((block_len % 4) == 0);
      icount = block_len / 4;
      iptr = (uint32_t *)block;
      for (size_t i=0; i<icount; i++)
	*sump += iptr[i];
    }
  }

}
