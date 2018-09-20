require 'csv'

module Export
  # Used to generate reports summarising submissions in the format needed for
  # feeding into Coda, the CCS finance system.
  class CodaFinanceReport < ToIO
    HEADER = [
      'RunID',
      'Nominal',
      'Customer Code',
      'Customer Name',
      'Contract ID',
      'Order Number',
      'Lot Description',
      'Inf Sales',
      'Commission',
      'Commission %',
      'End User',
      'Submitter',
      'Month',
      'M_Q'
    ].freeze

    def output_row(submission)
      output.puts(Row.new(submission, Customer.sectors[:central_government]).to_csv_line)
      output.puts(Row.new(submission, Customer.sectors[:wider_public_sector]).to_csv_line)
    end
  end
end
