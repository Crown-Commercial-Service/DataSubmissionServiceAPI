require 'csv'

module Ingest
  ##
  # Takes the +path+ to the download from AttachedFileDownloader and returns
  # a +Rows+ object for both invoices and orders, comprising the
  # row +data+ (as a CSV enumerable), +row_count+, +sheet_name+
  # and +type+ (invoice or order)
  #
  # +rows+ contains the combined row counts for both sheets
  class Converter
    class UnreadableFile < StandardError; end

    attr_reader :excel_temp_file

    Rows = Struct.new(:data, :row_count, :sheet_name, :type)

    def initialize(excel_temp_file)
      @excel_temp_file = excel_temp_file
    end

    def rows
      @rows ||= invoices.row_count + orders.row_count
    end

    def invoices
      @invoices ||= fetch_sheet('invoice')
    end

    def orders
      @orders ||= fetch_sheet('order')
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
      sheet_temp_file = excel_temp_file + '_' + type + '.csv'
      sheet_name = type == 'invoice' ? invoice_sheet_name : order_sheet_name

      return empty_rows if sheet_name.blank?

      command = "in2csv -l --sheet=\"#{sheet_name}\" --locale=en_GB --blanks --skipinitialspace --no-inference"\
                " #{excel_temp_file} > #{sheet_temp_file}"
      Ingest::CommandRunner.new(command).run!

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

    def invoice_sheet_name
      @invoice_sheet_name ||= sheets.find { |sheet| sheet.match(/(booking|finance|management|invoice)/i) }
    end

    def order_sheet_name
      @order_sheet_name ||= sheets.find { |sheet| sheet.match(/(order|contract)/i) }
    end
  end
end
