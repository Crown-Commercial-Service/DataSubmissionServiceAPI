require 'csv'

module Ingest
  ##
  # Take the +path+ to the download from AttachedFileDownloader and return
  # a +Rows+ object for all entry types via +[]+, comprising the
  # row +data+ (as a CSV enumerable), +row_count+, +sheet_name+
  # and +type+ (invoice or order)
  #
  # +rows+ contains the combined row counts for all sheets
  class Converter
    class UnreadableFile < StandardError; end

    SHEET_NAME_PATTERNS = {
      'invoice' => /(booking|finance|management|invoice)/i,
      'order'   => /(order|contract)/i,
      'other'   => /Briefs Received|ITQs|Bid Invitations|Live Sites|Utility Spend|Success Measures/i
    }.freeze

    attr_reader :excel_temp_file

    Rows = Struct.new(:data, :row_count, :sheet_name, :type)

    def initialize(excel_temp_file)
      @excel_temp_file = excel_temp_file
      @rows_for = {}
    end

    def rows_for(entry_type)
      @rows_for[entry_type] ||= fetch_sheet(entry_type)
    end

    def sheets
      @sheets ||= begin
        response = Ingest::CommandRunner.new("in2csv --names #{excel_temp_file}").run!

        return response.stdout if response.successful?

        raise UnreadableFile
      end
    end

    private

    def fetch_sheet(type)
      sheet_temp_file = "#{excel_temp_file}_#{type}.csv"
      sheet_name = sheet_name_for(type)

      return empty_rows if sheet_name.blank?

      command = "in2csv -l --sheet=\"#{sheet_name}\" --locale=en_GB --blanks --skipinitialspace --no-inference"\
                " #{excel_temp_file} > #{sheet_temp_file}"
      sheet = Ingest::CommandRunner.new(command).run!

      raise UnreadableFile if sheet.successful? == false

      row_count = fetch_row_count(sheet_temp_file)

      Rows.new(
        CSV.foreach(sheet_temp_file, headers: true, header_converters: ->(h) { h.strip }),
        row_count,
        sheet_name,
        type
      )
    end

    def empty_rows
      Rows.new([], 0, nil, nil)
    end

    def fetch_row_count(file)
      # Don't count empty rows
      command = "csvcut -S -C 'line_number' -x #{file} | wc -l | xargs"

      row_count = Ingest::CommandRunner.new(command).run!.stdout.first.to_i
      row_count -= 1 unless row_count.zero? # Handle empty results
      row_count
    end

    def sheet_name_for(entry_type)
      sheets.find { |sheet| sheet.match(SHEET_NAME_PATTERNS[entry_type]) }
    end
  end
end
