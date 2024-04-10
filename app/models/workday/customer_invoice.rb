module Workday
  class ConnectionError < StandardError; end

  class CustomerInvoice
    def initialize(workday_reference)
      @workday_reference = workday_reference
    end

    def invoice_details
      result = {}

      invoice_number = report_entry.at_xpath('wd:Invoice/@wd:Descriptor').text

      result[:invoice_number] = invoice_number.delete_prefix 'Customer Invoice: '
      result[:invoice_amount] = report_entry.at_xpath('wd:Invoice_Amount').text
      result[:payment_status] = report_entry.at_xpath('wd:Payment_Status/@wd:Descriptor').text
      result[:invoice_date] = report_entry.at_xpath('wd:Invoice_Date').text

      result
    end

    private

    def report_entry
      @report_entry ||= Nokogiri(customer_invoices_xml).xpath('//wd:Report_Entry')
    end

    def customer_invoices_xml
      @customer_invoices_xml ||= customer_invoices.to_s
    end

    def base_url
      if ENV['WORKDAY_TENANT'] == 'production'
        'https://wd3-services1.myworkday.com'
      else
        'https://wd3-impl-services1.workday.com'
      end
    end

    def customer_invoices
      @customer_invoices ||= begin
        result = HTTP.basic_auth(
          user: Workday.username,
          pass: Workday.api_password
        ).get(
          "#{base_url}/ccx/service/customreport2/#{Workday.tenant}/INT003_ISU/CR_Customer_Invoice_API?Customer_Invoice!WID=#{@workday_reference}"
        )

        raise Workday::ConnectionError unless result.status == 200

        result
      end
    end
  end
end
