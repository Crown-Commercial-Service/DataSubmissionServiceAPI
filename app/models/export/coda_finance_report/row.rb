module Export
  class CodaFinanceReport
    class Row < Export::CsvRow
      alias_method :submission, :model

      attr_reader :sector

      def initialize(submission, sector)
        super(submission)
        @sector = sector
      end

      def row_values
        [
          run_id,
          nominal,
          customer_code,
          customer_name,
          contract_id,
          order_number,
          lot_description,
          inf_sales,
          commission,
          commission_percent,
          end_user,
          submitter,
          month,
          m_q
        ]
      end

      def run_id
        submission.id
      end

      def nominal
        framework.coda_reference
      end

      def customer_code
        supplier.coda_reference
      end

      def customer_name
        supplier.name
      end

      def contract_id
        framework.short_name
      end

      def order_number
        BLANK_FOR_NOW
      end

      def lot_description
        framework.name
      end

      def inf_sales
        format_money(total_sales)
      end

      def commission
        format_money(management_charge)
      end

      def commission_percent
        format_percentage(management_charge_rate)
      end

      def end_user
        sector_identifier
      end

      def submitter
        supplier.name
      end

      def month
        task_period
      end

      def m_q
        monthly_or_quarterly
      end

      private

      def task_period
        Date.new(task.period_year, task.period_month).strftime('%B %Y')
      end

      def sector_identifier
        sector == Customer.sectors[:central_government] ? 'UCGV' : 'UWPS'
      end

      def total_sales
        submission.entries
                  .invoices
                  .sector(sector)
                  .sum { |entry| numeric_string_to_number(entry.data['Total Cost (ex VAT)']) }
      end

      def management_charge
        (total_sales * management_charge_rate / 100)
      end

      def management_charge_rate
        Framework::TMP_FIXED_CHARGE_RATE
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

      # Used to indicate if the data in the report is for monthly or quarterly
      # submissions. In reality, only monthly submissions are supported by both
      # the legacy and the new system and quarterly frameworks (of which there is
      # one?) is handled manually by CCS.
      def monthly_or_quarterly
        'M'
      end

      def framework
        @framework ||= submission.framework
      end

      def supplier
        @supplier ||= submission.supplier
      end

      def task
        @task ||= submission.task
      end
    end
  end
end
