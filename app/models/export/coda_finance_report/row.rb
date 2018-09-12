module Export
  class CodaFinanceReport
    class Row
      attr_reader :sector, :submission

      def initialize(submission, sector)
        @submission = submission
        @sector = sector
      end

      delegate :id, to: :submission, prefix: true
      delegate :coda_reference, :name, to: :supplier, prefix: true
      delegate :coda_reference, :name, :short_name, to: :framework, prefix: true

      def data
        @data ||= {
          'RunID' => submission_id,
          'Nominal' => framework_coda_reference,
          'Contract ID' => framework_short_name,
          'Lot Description' => framework_name,
          'Customer Code' => supplier_coda_reference,
          'Customer Name' => supplier_name,
          'Submitter' => supplier_name,
          'Month' => task_period,
          'End User' => sector_identifier,
          'Inf Sales' => format_money(total_sales),
          'Commission' => format_money(management_charge),
          'Commission %' => format_percentage(management_charge_rate)
        }
      end

      private

      def framework
        @framework ||= submission.framework
      end

      def supplier
        @supplier ||= submission.supplier
      end

      def task
        @task ||= submission.task
      end

      def task_period
        Date.new(task.period_year, task.period_month).strftime('%B %Y')
      end

      def sector_identifier
        sector == Customer.sectors[:central_government] ? 'UCGV' : 'UWPS'
      end

      def total_sales
        submission.entries
                  .sheet('InvoicesRaised')
                  .sector(sector)
                  .sum { |entry| numeric_string_to_number(entry.data['Total Cost (ex VAT)']) }
      end

      def management_charge
        (total_sales * management_charge_rate / 100)
      end

      def management_charge_rate
        BigDecimal('1.5')
      end

      def numeric_string_to_number(numeric_string)
        BigDecimal(numeric_string.delete(','))
      end

      def format_money(amount)
        format '%.2f', amount.truncate(2)
      end

      def format_percentage(percentage)
        (percentage / 100).to_s
      end
    end
  end
end
