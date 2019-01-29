module Workday
  class SubmitCustomerInvoiceRequest < Base
    def initialize(submission)
      @submission = submission
      @request = Workday.client.request('Submit_Customer_Invoice')

      prepare_request_body
      set_wsse_header
    end

    delegate :url, :content, to: :request

    def perform
      raw_response = HTTP.headers(request.headers).post(request.url, body: request.content)
      response = Workday.client.response(@request, raw_response)
      raise Fault, response.fault.reason if response.fault

      response.body_hash.fetch('Customer_Invoice_Reference').fetch('ID').first
    end

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
          invoice.Submit                  false

          invoice.Customer_Invoice_Line_Replacement_Data do |invoice_line|
            invoice_line.Line_Item_Description      line_item_description
            invoice_line.Extended_Amount            management_charge
            invoice_line.Analytical_Amount          total_spend
            invoice_line.Worktags_Reference.ID      framework.short_name, 'ns0:type': 'Custom_Organization_Reference_ID'
            invoice_line.Revenue_Category_Reference.ID framework_revenue_category_id, 'ns0:type': 'WID'
          end
        end
      end
    end
    # rubocop:enable Metrics/AbcSize

    def framework
      submission.framework
    end

    def framework_revenue_category_id
      framework.revenue_category_wid
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
