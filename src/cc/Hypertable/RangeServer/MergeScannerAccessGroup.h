/* -*- c++ -*-
 * Copyright (C) 2007-2016 Hypertable, Inc.
 *
 * This file is part of Hypertable.
 *
 * Hypertable is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; version 3 of the
 * License, or any later version.
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

/// @file
/// Declarations for MergeScannerAccessGroup.
/// This file contains the type declarations for MergeScannerAccessGroup, a
/// class used to perform a scan over an access group.

#ifndef Hypertable_RangeServer_MergeScannerAccessGroup_h
#define Hypertable_RangeServer_MergeScannerAccessGroup_h

#include "CellListScanner.h"
#include "CellStoreReleaseCallback.h"
#include "IndexUpdater.h"
#include "ScanContext.h"

#include <Common/ByteString.h>
#include <Common/DynamicBuffer.h>

#include <memory>
#include <queue>
#include <string>
#include <vector>
#include <set>

namespace Hypertable {

  /// @addtogroup RangeServer
  /// @{

  /// Merge scanner for access groups.
  class MergeScannerAccessGroup {

    class RegexpInfo {
    public:
      RegexpInfo()
      : last_family(-1), last_rowkey_match(false), last_column_match(false) { }

      void check_rowkey(const char *rowkey, bool *cached, bool *match) {
        *match = last_rowkey_match;
        if (!strcmp(rowkey, last_rowkey.c_str()))
          *cached = true;
        else
          *cached = false;
      }

      void check_column(int family, const char *qualifier, bool *cached,
          bool *match) {
          *match = last_column_match;
          if (last_family == family 
              && !strcmp(qualifier, last_qualifier.c_str()))
            *cached = true;
          else
            *cached = false;
      }

      void set_rowkey(const char *rowkey, bool match) {
        last_rowkey = rowkey;
        last_rowkey_match = match;
      }

      void set_column(int family, const char *qualifier, bool match) {
        last_family = family;
        last_qualifier = qualifier;
        last_column_match = match;
      }

    private:
      String last_rowkey;
      String last_qualifier;
      int last_family;
      bool last_rowkey_match;
      bool last_column_match;
    };

    struct ScannerState {
      CellListScanner *scanner;
      Key key;
      ByteString value;
    };

    struct LtScannerState {
      bool operator()(const ScannerState &ss1, const ScannerState &ss2) const {
        return ss1.key.serial > ss2.key.serial;
      }
    };

  public:

    enum Flags {
      RETURN_DELETES = 0x00000001,
      IS_COMPACTION = 0x00000002,
      ACCUMULATE_COUNTERS = 0x00000004
    };

    /// Constructor.
    /// @param table_name Table name
    /// @param scan_ctx Scan context
    /// @param flags Flags
    MergeScannerAccessGroup(String &table_name, ScanContext *scan_ctx,
                            uint32_t flags=0);

    /// Destructor.
    /// Destroys all scanners in #m_scanners and then calls #m_release_callback
    virtual ~MergeScannerAccessGroup();

    void add_scanner(CellListScannerPtr scanner) {
      m_scanners.push_back(scanner);
    }

    void forward();

    bool get(Key &key, ByteString &value);

    uint32_t get_flags() { return m_flags; }

    void install_release_callback(CellStoreReleaseCallback &cb) {
      m_release_callback = cb;
    }

    void io_add_input_cell(int64_t cur_bytes) {
      m_bytes_input += cur_bytes;
      m_cells_input++;
    }

    void io_add_output_cell(int64_t cur_bytes) {
      m_bytes_output += cur_bytes;
      m_cells_output++;
    }

    int64_t get_input_cells() { return m_cells_input; }
    int64_t get_output_cells() { return m_cells_output; }

    int64_t get_input_bytes() { return m_bytes_input; }
    int64_t get_output_bytes() { return m_bytes_output; }

    void add_disk_read(int64_t amount) { m_disk_read += amount; }
    int64_t get_disk_read();

  private:

    void initialize();

    inline bool matches_deleted_row(const Key& key) const {
      size_t len = key.len_row();

      HT_DEBUG_OUT <<"filtering deleted row '"
          << String((char*)m_deleted_row.base, m_deleted_row.fill()) <<"' vs '"
          << String(key.row, len) <<"'" << HT_END;

      return (m_delete_present && m_deleted_row.fill() > 0
              && m_deleted_row.fill() == len
              && !memcmp(m_deleted_row.base, key.row, len));
    }

    inline void update_deleted_row(const Key& key) {
      size_t len = key.len_row();
      m_deleted_row.clear();
      m_deleted_row.ensure(len);
      memcpy(m_deleted_row.base, key.row, len);
      m_deleted_row.ptr = m_deleted_row.base + len;
      m_deleted_row_timestamp = key.timestamp;
      m_delete_present = true;
    }

    inline bool matches_deleted_column_family(const Key& key) const {
      size_t len = key.len_column_family();

      HT_DEBUG_OUT <<"filtering deleted row-column-family '"
          << String((char*)m_deleted_column_family.base,
                    m_deleted_column_family.fill())
          <<"' vs '"<< String(key.row, len) <<"'" << HT_END;

      return (m_delete_present && m_deleted_column_family.fill() > 0
              && m_deleted_column_family.fill() == len
              && !memcmp(m_deleted_column_family.base, key.row, len));
    }

    inline void update_deleted_column_family(const Key &key) {
      size_t len = key.len_column_family();
      m_deleted_column_family.clear();
      m_deleted_column_family.ensure(len);
      memcpy(m_deleted_column_family.base, key.row, len);
      m_deleted_column_family.ptr = m_deleted_column_family.base + len;
      m_deleted_column_family_timestamp = key.timestamp;
      m_delete_present = true;
    }

    inline bool matches_deleted_cell(const Key& key) const {
      size_t len = key.len_cell();

      HT_DEBUG_OUT <<"filtering deleted cell '"
          << String((char*)m_deleted_cell.base, m_deleted_cell.fill())
          <<"' vs '"<< String(key.row, len) <<"'" << HT_END;

      return (m_delete_present && m_deleted_cell.fill() > 0
              &&  m_deleted_cell.fill() == len
              && !memcmp(m_deleted_cell.base, key.row, len));
    }

    inline void update_deleted_cell(const Key &key) {
      size_t len = key.len_cell();
      m_deleted_cell.clear();
      m_deleted_cell.ensure(len);
      memcpy(m_deleted_cell.base, key.row, len);
      m_deleted_cell.ptr = m_deleted_cell.base + len;
      m_deleted_cell_timestamp = key.timestamp;
      m_delete_present = true;
    }

    inline bool matches_deleted_cell_version(const Key& key) const {
      size_t len = key.len_cell();

      HT_DEBUG_OUT <<"filtering deleted cell version'"
          << String((char*)m_deleted_cell_version.base, 
            m_deleted_cell_version.fill())
          <<"' vs '"<< String(key.row, len) <<"'" << HT_END;

      return (m_delete_present && m_deleted_cell_version.fill() > 0
              &&  m_deleted_cell_version.fill() == len
              && !memcmp(m_deleted_cell_version.base, key.row, len));
    }

    inline void update_deleted_cell_version(const Key &key) {
      size_t len = key.len_cell();
      m_deleted_cell_version.clear();
      m_deleted_cell_version.ensure(len);
      memcpy(m_deleted_cell_version.base, key.row, len);
      m_deleted_cell_version.ptr = m_deleted_cell_version.base + len;
      m_deleted_cell_version_set.insert(key.timestamp);
      m_delete_present = true;
    }

    inline bool matches_counted_key(const Key& key) const {
      size_t len = key.len_cell();
      size_t len_counted_key = m_counted_key.len_cell();

      return (m_count_present && len == len_counted_key &&
              !memcmp(m_counted_key.row, key.row, len));
    }

    inline void increment_count(const Key &key, const ByteString &value) {
      if (m_skip_remaining_counter)
        return;
      const uint8_t *decode;
      size_t remain = value.decode_length(&decode);
      // value must be encoded 64 bit int
      if (remain != 8 && remain != 9) {
        HT_FATAL_OUT << "Expected counter to be encoded 64 bit int but "
            "remain=" << remain << " ,key=" << key << HT_END;
      }
      m_count += Serialization::decode_i64(&decode, &remain);
      if (remain == 1) {
        if ((char)*decode != '=')
          HT_FATAL_OUT << "Bad counter reset flag, expected '=' but "
            "got " << (int)*decode << HT_END;
        m_skip_remaining_counter = true;
      }
    }

    inline void finish_count() {
      uint8_t *ptr = m_counted_value.base;

      *ptr++ = 9;  // length
      Serialization::encode_i64(&ptr, m_count);
      *ptr++ = '=';

      m_prev_key.set(m_counted_key.row, m_counted_key.len_cell());
      m_prev_cf = m_counted_key.column_family_code;
      m_no_forward = true;
      m_count_present = false;
      m_skip_remaining_counter = false;
    }

    inline void start_count(const Key &key, const ByteString &value) {
      SerializedKey serial;
    
      m_count_present = true;
      m_count = 0;
    
      m_counted_key_buffer.clear();
      m_counted_key_buffer.ensure(key.length);
      memcpy(m_counted_key_buffer.base, key.serial.ptr, key.length);
      serial.ptr = m_counted_key_buffer.base;

      m_counted_key.load(serial);
      increment_count(key, value);
    }

    inline void purge_from_index(const Key &key, const ByteString &value) {
      HT_ASSERT(key.flag == FLAG_INSERT);
      if (m_scan_context->cell_predicates[key.column_family_code].indexed)
        m_index_updater->purge(key, value);
    }

    CellStoreReleaseCallback m_release_callback;

    uint32_t m_flags {};
    bool m_done {};
    bool m_initialized {};

    std::vector<CellListScannerPtr>  m_scanners;
    std::priority_queue<ScannerState, std::vector<ScannerState>,
        LtScannerState> m_queue;


    int64_t m_bytes_input {};
    int64_t m_bytes_output {};
    int64_t m_cells_input {};
    int64_t m_cells_output {};
    int64_t m_disk_read {};

    // if this is true, return a delete even if it doesn't satisfy
    // the ScanSpec timestamp/version requirement
    bool          m_return_deletes;
    bool          m_accumulate_counters;

    // to avoid performance problems, the revision limit is checked in this 
    // class and not in MergeScannerRange. otherwise this class would send
    // ALL revisions to the upper level, even if just one would be required.
    uint32_t m_revs_count {};
    uint32_t m_revs_limit {};

    DynamicBuffer m_prev_key {};
    int32_t m_prev_cf;
    bool m_no_forward {};
    bool m_count_present {};
    bool m_skip_remaining_counter {};
    DynamicBuffer m_counted_key_buffer;
    uint64_t      m_count;
    Key           m_counted_key;
    DynamicBuffer m_counted_value;
    int64_t       m_start_timestamp;
    int64_t       m_end_timestamp;
    int64_t       m_revision;
    RegexpInfo    m_regexp_cache;
    bool m_delete_present {};
    DynamicBuffer m_deleted_row {};
    int64_t m_deleted_row_timestamp;
    DynamicBuffer m_deleted_column_family {};
    int64_t m_deleted_column_family_timestamp;
    DynamicBuffer m_deleted_cell {};
    int64_t m_deleted_cell_timestamp;
    DynamicBuffer m_deleted_cell_version {};
    std::set<int64_t> m_deleted_cell_version_set;
    IndexUpdaterPtr m_index_updater;

    ScanContext*  m_scan_context;

  };

  /// Shared pointer to MergeScannerAccessGroup
  typedef std::shared_ptr<MergeScannerAccessGroup> MergeScannerAccessGroupPtr;

  /// @}

} // namespace Hypertable

#endif // Hypertable_RangeServer_MergeScannerAccessGroup_h
