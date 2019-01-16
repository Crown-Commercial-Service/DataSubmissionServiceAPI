require 'lolsoap'

module Workday
  CCS_COMPANY_REFERENCE = 'Crown_Commercial_Service'.freeze

  class SubmitCustomerInvoiceRequest
    def initialize(submission)
      @submission = submission
      @client = LolSoap::Client.new(File.read('data/workday_revenue_management_v31.0.xml'))
      @request = @client.request('Submit_Customer_Invoice')

      prepare_request_body
    end

    delegate :url, :content, to: :request

    private

    attr_reader :request, :submission

    # rubocop:disable Metrics/AbcSize
    def prepare_request_body
      @request.body do |body|
        body.Customer_Invoice_Data do |invoice|
          invoice.Company_Reference.ID    CCS_COMPANY_REFERENCE, 'ns0:type': 'Company_Reference_ID'
          invoice.Customer_Reference.ID   supplier_salesforce_id, 'ns0:type': 'Customer_Reference_ID'
          invoice.From_Date               task.period_date.to_s
          invoice.Customer_PO_Number      submission.purchase_order_number
          invoice.Memo                    invoice_memo

          invoice.Customer_Invoice_Line_Replacement_Data do |invoice_line|
            invoice_line.Line_Item_Description      line_item_description
            invoice_line.Extended_Amount            management_charge
            invoice_line.Analytical_Amount          total_spend
            invoice_line.Revenue_Category_Reference.ID framework_revenue_category_id, 'ns0:type': 'WID'
            invoice_line.Worktags_Reference.ID      framework_cost_center_id, 'ns0:type': 'WID'
            invoice_line.Worktags_Reference.ID      framework.short_name, 'ns0:type': 'Custom_Organization_Reference_ID'
          end
        end
      end
    end
    # rubocop:enable Metrics/AbcSize

    def framework
      submission.framework
    end

    # NOTE: Hardcoded until we have access to the endpoint to identify this ID in Workday
    def framework_cost_center_id
      'e02956ef5ea301814e48cb47a267e959'
    end

    # NOTE: Hardcoded until we have access to the endpoint to identify this ID in Workday
    def framework_revenue_category_id
      'a2f06ac13aa001298fa4baeb696a06f3'
    end

    def invoice_memo
      "Submission ID: #{submission.id}"
    end

    def line_item_description
      "Management charge for #{task_period_in_words} based on £#{total_spend} spend"
    end

    def management_charge
      format '%.2f', submission.management_charge.truncate(2)
    end

    def total_spend
      format '%.2f', submission.total_spend.truncate(2)
    end

    def supplier_salesforce_id
      submission.supplier.salesforce_id
    end

    def task
      submission.task
    end

    def task_period_in_words
      task.period_date.strftime('%B %Y')
    end
  end
end
