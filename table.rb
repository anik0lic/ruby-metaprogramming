require "google_drive"

class Table
    include Enumerable

    attr_accessor :spreadsheet_id, :worksheet, :worksheet_number, :headers, :

    def initialize(spreadsheet_id, worksheet_number)
      @spreadsheet_id = spreadsheet_id
      @worksheet_number = worksheet_number
      @worksheet = authenticate_google
      @headers = worksheet.rows[0]
    end

    def authenticate_google
        session = GoogleDrive::Session.from_config("config.json")
        session.spreadsheet_by_key("1-a1rlP_3fkneVTSDBto7ewW5snB8pRxSysw8HlQnz1M").worksheets[worksheet_number]
    end

    def print
        puts "Headers: #{headers}"

        worksheet.rows[1..-1].each do |row|
            puts "Row: #{row}"
        end
    end

    def row(row_number)
        puts "Row #{row_number}: #{worksheet.rows[row_number]}"
    end

    def [](header)
        header_index = headers.index(header)

        return nil unless header_index

        column = worksheet.rows[1..-1].map { |row| row[header_index] }
        Column.new(column, worksheet, header_index)
    end

    def method_missing(method_name, *args)
        modified_string = method_name.to_s.gsub(/\b\w/, &:capitalize)
        header_index = headers.index(modified_string)

        return nil unless header_index

        column = worksheet.rows[1..-1].map { |row| row[header_index] }
        Column.new(column, worksheet, header_index)
    end

    def each(&_block)
        worksheet.rows[1..-1].each do |row|
            row_str = row.join(", ")
            yield(row_str)
        end
    end

    def sum_tables(t2)
        raise 'Tables must have the same dimensions' unless self.headers == t2.headers

        result = worksheet.dup 

        worksheet.rows[1..-1].each_with_index do |row, i|
            new_row = row.map.with_index do |cell, j|
                cell.to_f + t2.worksheet.rows[i][j].to_f
            end
            worksheet.rows[i] = new_row
        end
    end

    def minus_tables(t2)
        raise 'Tables must have the same dimensions' unless self.headers == t2.headers

        result = worksheet.dup 

        worksheet.rows[1..-1].each_with_index do |row, i|
            new_row = row.map.with_index do |cell, j|
                cell.to_f - t2.worksheet.rows[i][j].to_f
            end
            worksheet.rows[i] = new_row
        end
    end
end

class Column
    include Enumerable

    attr_accessor :column, :worksheet, :header_index

    def initialize(column, worksheet, header_index)
      @column = column
      @worksheet = worksheet
      @header_index = header_index
    end

    def [](index)
      column[index - 1]
    end

    def []=(index, value)
      worksheet[index + 1, header_index + 1] = value
      column[index + 1] = value

      reload_column
    end

    def sum
        num_column = column.map(&:to_i)
        num_column.compact.sum
    end

    def avg
        num_column = column.map(&:to_i)
        values = num_column.compact
        none_zero = values.reject { |num| num.zero? }

        none_zero.empty? ? nil : none_zero.sum / none_zero.length.to_f
    end

    def method_missing(method_name, *args)
        row_index = column.index(method_name.to_s)

        return nil unless row_index

        worksheet.rows[row_index + 1]
    end

    def to_s
        column.map(&:to_s).join(' ')
    end

    def map(&_block)
        num_column = column.map(&:to_i)
        num_column.map do |row|
            yield(row)
        end
    end

    def select(&_block)
        num_column = column.map(&:to_i)
        num_column.select do |row|
            yield(row)
        end
    end

    def reduce(n = nil, &_block)
        num_column = column.map(&:to_i)
        num_column.reduce do |n, row|
            yield(n, row)
        end
    end

    private

    def reload_column
      column = worksheet.rows[1..-1].map { |row| row[header_index] }
    end
end
