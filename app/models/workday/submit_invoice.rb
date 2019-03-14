module Workday
  class SubmitInvoice < Base
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
        body.Business_Process_Parameters.Auto_Complete true
        body.Customer_Invoice_Data do |invoice|
          invoice.Company_Reference.ID    CCS_COMPANY_REFERENCE, 'ns0:type': 'Company_Reference_ID'
          invoice.Customer_Reference.ID   supplier_salesforce_id, 'ns0:type': 'Customer_Reference_ID'
          invoice.From_Date               task.period_date.to_s
          invoice.Customer_PO_Number      submission.purchase_order_number
          invoice.Memo                    invoice_memo
          invoice.Submit                  true
          invoice.Note_Data.Note_Content  submitted_by_note_content

          invoice.Customer_Invoice_Line_Replacement_Data do |invoice_line|
            invoice_line.Line_Item_Description      line_item_description
            invoice_line.Extended_Amount            formatted_management_charge
            invoice_line.Analytical_Amount          formatted_total_spend
            invoice_line.Worktags_Reference.ID      framework.short_name, 'ns0:type': 'Custom_Organization_Reference_ID'
            invoice_line.Tax_Code_Reference.ID      tax_code_id, 'ns0:type': 'Tax_Code_ID'
            invoice_line.Revenue_Category_Reference.ID framework_revenue_category_id, 'ns0:type': 'Revenue_Category_ID'
          end
        end
      end
    end
    # rubocop:enable Metrics/AbcSize

    def framework
      submission.framework
    end

    def workday_commercial_agreements
      Workday::CommercialAgreements.new
    end

    def framework_revenue_category_id
      workday_commercial_agreements.revenue_category_ids[framework.short_name]
    end

    def tax_code_id
      workday_commercial_agreements.tax_code_ids[framework.short_name]
    end

    def invoice_memo
      "Submission ID: #{submission.id}"
    end

    def submitted_by_note_content
      submission.submitted_by.name if submission.submitted_by.present?
    end

    def line_item_description
      "Management charge for #{task_period_in_words} based on £#{formatted_total_spend} spend"
    end

    # "Extended_Amount", which is the management_charge, must always be expressed as a positive number
    def management_charge
      submission.management_charge.abs
    end

    def formatted_management_charge
      format '%.2f', management_charge.truncate(2)
    end

    def total_spend
      submission.total_spend
    end

    def formatted_total_spend
      format '%.2f', total_spend.truncate(2)
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
