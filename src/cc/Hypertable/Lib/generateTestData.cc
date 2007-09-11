/**
 * Copyright (C) 2007 Doug Judd (Zvents, Inc.)
 * 
 * This file is part of Hypertable.
 * 
 * Hypertable is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or any later version.
 * 
 * Hypertable is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include <cstring>
#include <string>
#include <vector>

extern "C" {
#include <string.h>
#include <sys/time.h>
}

#include "Common/Error.h"
#include "Common/System.h"
#include "Common/TestHarness.h"
#include "Common/Usage.h"

#include "Hypertable/Lib/Manager.h"
#include "Hypertable/Lib/Schema.h"

#include "TestData.h"


using namespace hypertable;
using namespace std;

namespace {
  const char *usage[] = {
    "usage: generateTestData [OPTIONS] <tableName>",
    "",
    "OPTINS:",
    "  --config=<fname>  Read configuration properties from <fname>",
    "  --seed=<n>        Seed the randon number generator with <n>",
    "  --timestamps      Generate timestamps",
    "",
    "This program generates random test data to stdout.  It",
    "contacts the master server and fetches the schema for",
    "the given table <tableName> and creates random test",
    "data for the table.  It requires the following input",
    "files to be located under ../demo relative to the",
    "location of the generateTestData binary:",
    "",
    "shakespeare.txt.gz",
    "urls.txt.gz",
    "words.gz",
    "",
    "Approximately 1 out of 50 lines will be row deletes and",
    "1 out of 30 lines will be cell deletes.  The rest are normal",
    "inserts.  Each emitted line has one of the following",
    "formats:",
    "",
    "<timestamp> '\\t' <rowKey> '\\t' <qualifiedColumn> '\\t' <value>",
    "<timestamp> '\\t' <rowKey> '\\t' <qualifiedColumn> '\\t' DELETE",
    "<timestamp> '\\t' DELETE",
    "",
    "The <timestamp> field will contain the word AUTO unless the",
    "--timestamp argument was supplied, in which case it will contain",
    "the number of microseconds since the epoch that have elapsed at",
    "the time the line was emitted.",
    0
  };
}


int main(int argc, char **argv) {
  TestData tdata;
  Schema *schema;
  std::string schemaSpec;
  off_t len;
  struct timeval tval;
  uint64_t timestamp;
  uint32_t index;
  const char *rowKey;
  const char *qualifier;
  uint8_t family;
  const char *content, *ptr;
  std::string value;
  size_t cfMax;
  vector<std::string> cfNames;
  int modValue;
  std::string configFile = "";
  Manager *manager;
  int error;
  std::string tableName = "";
  unsigned int seed = 1234;
  bool generateTimestamps = false;

  System::Initialize(argv[0]);
  ReactorFactory::Initialize((uint16_t)System::GetProcessorCount());

  for (int i=1; i<argc; i++) {
    if (!strncmp(argv[i], "--config=", 9))
      configFile = &argv[i][9];
    else if (!strncmp(argv[i], "--seed=", 7)) {
      seed = atoi(&argv[i][7]);
    }
    else if (!strcmp(argv[i], "--timestamps")) {
      generateTimestamps = true;
    }
    else if (tableName == "")
      tableName = argv[i];
    else
      Usage::DumpAndExit(usage);
  }

  if (tableName == "")
    Usage::DumpAndExit(usage);

  if (configFile == "")
    configFile = System::installDir + "/conf/hypertable.cfg";

  if (!tdata.Load(System::installDir + "/demo"))
    exit(1);

  manager = new Manager(configFile);

  if ((error = manager->GetSchema(tableName, schemaSpec)) != Error::OK) {
    LOG_VA_ERROR("Problem getting schema for table '%s' - %s", argv[1], Error::GetText(error));
    return error;
  }

  schema = Schema::NewInstance(schemaSpec.c_str(), strlen(schemaSpec.c_str()), true);
  if (!schema->IsValid()) {
    LOG_VA_ERROR("Schema Parse Error: %s", schema->GetErrorString());
    exit(1);
  }

  cfMax = schema->GetMaxColumnFamilyId();
  cfNames.resize(cfMax+1);

  list<Schema::AccessGroup *> *lgList = schema->GetAccessGroupList();
  for (list<Schema::AccessGroup *>::iterator iter = lgList->begin(); iter != lgList->end(); iter++) {
    for (list<Schema::ColumnFamily *>::iterator cfIter = (*iter)->columns.begin(); cfIter != (*iter)->columns.end(); cfIter++)
      cfNames[(*cfIter)->id] = (*cfIter)->name;
  }

  srand(seed);

  while (true) {

    if (generateTimestamps) {
      // timestamp
      gettimeofday(&tval, 0);
      timestamp = ((uint64_t)tval.tv_sec * 1000000LL) + tval.tv_usec;
    }

    // row key
    index = rand() % tdata.words.size();
    rowKey = tdata.words[index].get();

    index = rand();
    modValue = rand() % 49;
    if ((index % 49) == (size_t)modValue) {
      if (generateTimestamps)
	cout << timestamp << "\t" << rowKey << "\tDELETE" << endl;
      else
	cout << "AUTO\t" << rowKey << "\tDELETE" << endl;	
      continue;
    }

    index = rand();
    family = (index % cfMax) + 1;
    
    index = rand() % tdata.urls.size();
    qualifier = tdata.urls[index].get();

    index = rand();
    modValue = rand() % 29;
    if ((index % 29) == 0) {
      if (generateTimestamps)
	cout << timestamp << "\t" << rowKey << "\t" << cfNames[family] << ":" << qualifier << "\tDELETE" << endl;
      else
	cout << "AUTO\t" << rowKey << "\t" << cfNames[family] << ":" << qualifier << "\tDELETE" << endl;
      continue;
    }

    index = rand() % tdata.content.size();
    content = tdata.content[index].get();
    
    if ((ptr = strchr(content, '\n')) != 0)
      value = std::string(content, ptr-content);
    else
      value = content;

    if (generateTimestamps)
      cout << timestamp << "\t" << rowKey << "\t" << cfNames[family] << ":" << qualifier << "\t" << value << endl;    
    else
      cout << "AUTO\t" << rowKey << "\t" << cfNames[family] << ":" << qualifier << "\t" << value << endl;    
  }

  return 0;
}
