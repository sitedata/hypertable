#
# Autogenerated by Thrift
#
# DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
#


module Hypertable
  module ThriftGen
        module CellFlag
          DELETE_ROW = 0
          DELETE_CF = 1
          DELETE_CELL = 2
          INSERT = 255
          VALUE_MAP = {0 => "DELETE_ROW", 1 => "DELETE_CF", 2 => "DELETE_CELL", 255 => "INSERT"}
          VALID_VALUES = Set.new([DELETE_ROW, DELETE_CF, DELETE_CELL, INSERT]).freeze
        end

        module MutatorFlag
          NO_LOG_SYNC = 1
          VALUE_MAP = {1 => "NO_LOG_SYNC"}
          VALID_VALUES = Set.new([NO_LOG_SYNC]).freeze
        end

        # Specifies a range of rows
        # 
        # <dl>
        #   <dt>start_row</dt>
        #   <dd>The row to start scan with. Must not contain nulls (0x00)</dd>
        # 
        #   <dt>start_inclusive</dt>
        #   <dd>Whether the start row is included in the result (default: true)</dd>
        # 
        #   <dt>end_row</dt>
        #   <dd>The row to end scan with. Must not contain nulls</dd>
        # 
        #   <dt>end_inclusive</dt>
        #   <dd>Whether the end row is included in the result (default: true)</dd>
        # </dl>
        class RowInterval
          include ::Thrift::Struct
          START_ROW = 1
          START_INCLUSIVE = 2
          END_ROW = 3
          END_INCLUSIVE = 4

          ::Thrift::Struct.field_accessor self, :start_row, :start_inclusive, :end_row, :end_inclusive
          FIELDS = {
            START_ROW => {:type => ::Thrift::Types::STRING, :name => 'start_row', :optional => true},
            START_INCLUSIVE => {:type => ::Thrift::Types::BOOL, :name => 'start_inclusive', :default => true, :optional => true},
            END_ROW => {:type => ::Thrift::Types::STRING, :name => 'end_row', :optional => true},
            END_INCLUSIVE => {:type => ::Thrift::Types::BOOL, :name => 'end_inclusive', :default => true, :optional => true}
          }

          def struct_fields; FIELDS; end

          def validate
          end

        end

        # Specifies a range of cells
        # 
        # <dl>
        #   <dt>start_row</dt>
        #   <dd>The row to start scan with. Must not contain nulls (0x00)</dd>
        # 
        #   <dt>start_column</dt>
        #   <dd>The column (prefix of column_family:column_qualifier) of the
        #   start row for the scan</dd>
        # 
        #   <dt>start_inclusive</dt>
        #   <dd>Whether the start row is included in the result (default: true)</dd>
        # 
        #   <dt>end_row</dt>
        #   <dd>The row to end scan with. Must not contain nulls</dd>
        # 
        #   <dt>end_column</dt>
        #   <dd>The column (prefix of column_family:column_qualifier) of the
        #   end row for the scan</dd>
        # 
        #   <dt>end_inclusive</dt>
        #   <dd>Whether the end row is included in the result (default: true)</dd>
        # </dl>
        class CellInterval
          include ::Thrift::Struct
          START_ROW = 1
          START_COLUMN = 2
          START_INCLUSIVE = 3
          END_ROW = 4
          END_COLUMN = 5
          END_INCLUSIVE = 6

          ::Thrift::Struct.field_accessor self, :start_row, :start_column, :start_inclusive, :end_row, :end_column, :end_inclusive
          FIELDS = {
            START_ROW => {:type => ::Thrift::Types::STRING, :name => 'start_row', :optional => true},
            START_COLUMN => {:type => ::Thrift::Types::STRING, :name => 'start_column', :optional => true},
            START_INCLUSIVE => {:type => ::Thrift::Types::BOOL, :name => 'start_inclusive', :default => true, :optional => true},
            END_ROW => {:type => ::Thrift::Types::STRING, :name => 'end_row', :optional => true},
            END_COLUMN => {:type => ::Thrift::Types::STRING, :name => 'end_column', :optional => true},
            END_INCLUSIVE => {:type => ::Thrift::Types::BOOL, :name => 'end_inclusive', :default => true, :optional => true}
          }

          def struct_fields; FIELDS; end

          def validate
          end

        end

        # Specifies options for a scan
        # 
        # <dl>
        #   <dt>row_intervals</dt>
        #   <dd>A list of ranges of rows to scan. Mutually exclusive with
        #   cell_interval</dd>
        # 
        #   <dt>cell_intervals</dt>
        #   <dd>A list of ranges of cells to scan. Mutually exclusive with
        #   row_intervals</dd>
        # 
        #   <dt>return_deletes</dt>
        #   <dd>Indicates whether cells pending delete are returned</dd>
        # 
        #   <dt>revs</dt>
        #   <dd>Specifies max number of revisions of cells to return</dd>
        # 
        #   <dt>row_limit</dt>
        #   <dd>Specifies max number of rows to return</dd>
        # 
        #   <dt>start_time</dt>
        #   <dd>Specifies start time in nanoseconds since epoch for cells to
        #   return</dd>
        # 
        #   <dt>end_time</dt>
        #   <dd>Specifies end time in nanoseconds since epoch for cells to return</dd>
        # 
        #   <dt>columns</dt>
        #   <dd>Specifies the names of the columns to return</dd>
        # </dl>
        class ScanSpec
          include ::Thrift::Struct
          ROW_INTERVALS = 1
          CELL_INTERVALS = 2
          RETURN_DELETES = 3
          REVS = 4
          ROW_LIMIT = 5
          START_TIME = 6
          END_TIME = 7
          COLUMNS = 8

          ::Thrift::Struct.field_accessor self, :row_intervals, :cell_intervals, :return_deletes, :revs, :row_limit, :start_time, :end_time, :columns
          FIELDS = {
            ROW_INTERVALS => {:type => ::Thrift::Types::LIST, :name => 'row_intervals', :element => {:type => ::Thrift::Types::STRUCT, :class => Hypertable::ThriftGen::RowInterval}, :optional => true},
            CELL_INTERVALS => {:type => ::Thrift::Types::LIST, :name => 'cell_intervals', :element => {:type => ::Thrift::Types::STRUCT, :class => Hypertable::ThriftGen::CellInterval}, :optional => true},
            RETURN_DELETES => {:type => ::Thrift::Types::BOOL, :name => 'return_deletes', :default => false, :optional => true},
            REVS => {:type => ::Thrift::Types::I32, :name => 'revs', :default => 0, :optional => true},
            ROW_LIMIT => {:type => ::Thrift::Types::I32, :name => 'row_limit', :default => 0, :optional => true},
            START_TIME => {:type => ::Thrift::Types::I64, :name => 'start_time', :optional => true},
            END_TIME => {:type => ::Thrift::Types::I64, :name => 'end_time', :optional => true},
            COLUMNS => {:type => ::Thrift::Types::LIST, :name => 'columns', :element => {:type => ::Thrift::Types::STRING}, :optional => true}
          }

          def struct_fields; FIELDS; end

          def validate
          end

        end

        # Defines a table cell
        # 
        # <dl>
        #   <dt>row_key</dt>
        #   <dd>Specifies the row key. Note, it cannot contain null characters.
        #   If a row key is not specified in a return cell, it's assumed to
        #   be the same as the previous cell</dd>
        # 
        #   <dt>column_family</dt>
        #   <dd>Specifies the column family</dd>
        # 
        #   <dt>column_qualifier</dt>
        #   <dd>Specifies the column qualifier. A column family must be specified.</dd>
        # 
        #   <dt>value</dt>
        #   <dd>Value of a cell. Currently a sequence of uninterpreted bytes.</dd>
        # 
        #   <dt>timestamp</dt>
        #   <dd>Nanoseconds since epoch for the cell<dd>
        # 
        #   <dt>revision</dt>
        #   <dd>A 64-bit revision number for the cell</dd>
        # 
        #   <dt>flag</dt>
        #   <dd>A 16-bit integer indicating the state of the cell</dd>
        # </dl>
        class Cell
          include ::Thrift::Struct
          ROW_KEY = 1
          COLUMN_FAMILY = 2
          COLUMN_QUALIFIER = 3
          VALUE = 4
          TIMESTAMP = 5
          REVISION = 6
          FLAG = 7

          ::Thrift::Struct.field_accessor self, :row_key, :column_family, :column_qualifier, :value, :timestamp, :revision, :flag
          FIELDS = {
            ROW_KEY => {:type => ::Thrift::Types::STRING, :name => 'row_key', :optional => true},
            COLUMN_FAMILY => {:type => ::Thrift::Types::STRING, :name => 'column_family', :optional => true},
            COLUMN_QUALIFIER => {:type => ::Thrift::Types::STRING, :name => 'column_qualifier', :optional => true},
            VALUE => {:type => ::Thrift::Types::STRING, :name => 'value', :optional => true},
            TIMESTAMP => {:type => ::Thrift::Types::I64, :name => 'timestamp', :optional => true},
            REVISION => {:type => ::Thrift::Types::I64, :name => 'revision', :optional => true},
            FLAG => {:type => ::Thrift::Types::I16, :name => 'flag', :default => 255, :optional => true}
          }

          def struct_fields; FIELDS; end

          def validate
          end

        end

        # Exception for thrift clients.
        # 
        # <dl>
        #   <dt>code</dt><dd>Internal use (defined in src/cc/Common/Error.h)</dd>
        #   <dt>what</dt><dd>A message about the exception</dd>
        # </dl>
        # 
        # Note: some languages (like php) don't have adequate namespace, so Exception
        # would conflict with language builtins.
        class ClientException < ::Thrift::Exception
          include ::Thrift::Struct
          CODE = 1
          WHAT = 2

          ::Thrift::Struct.field_accessor self, :code, :what
          FIELDS = {
            CODE => {:type => ::Thrift::Types::I32, :name => 'code'},
            WHAT => {:type => ::Thrift::Types::STRING, :name => 'what'}
          }

          def struct_fields; FIELDS; end

          def validate
          end

        end

      end
    end
