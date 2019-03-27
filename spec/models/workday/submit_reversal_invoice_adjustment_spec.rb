require 'rails_helper'

RSpec.describe Workday::SubmitReversalInvoiceAdjustment do
  let(:user) { FactoryBot.create(:user, name: 'Forename Surname') }
  let(:correcting_user) { FactoryBot.create(:user, name: 'ForenameR SurnameR') }
  let(:submission) do
    FactoryBot.create(:submission_with_validated_entries,
                      purchase_order_number: '123',
                      submitted_by: user,
                      task: task)
  end
  let(:framework) { submission.framework }
  let(:task) { FactoryBot.create(:task, period_month: 12, period_year: 2018) }
  let(:supplier) { submission.supplier }
  let(:request) { Workday::SubmitReversalInvoiceAdjustment.new(submission, correcting_user) }

  before do
    commercial_agreements = double(
      revenue_category_ids: { framework.short_name => 'Revenue_Category_WID' },
      tax_code_ids: { framework.short_name => 'GBC20' }
    )
    allow(Workday::CommercialAgreements).to receive(:new).and_return(commercial_agreements)
  end

  it_behaves_like 'a workday request'

  describe '#content' do
    it_behaves_like 'an authenticated workday request'

    it 'sets Company_Reference with the CCS Workday Company_Reference_ID' do
      expect(
        text_at_xpath("//ns0:Company_Reference//ns0:ID[@ns0:type='Company_Reference_ID']")
      ).to eq 'Crown_Commercial_Service'
    end

    it 'sets Customer_Reference with the Supplier’s salesforce_id identified as Customer_Reference_ID' do
      expect(
        text_at_xpath("//ns0:Customer_Reference//ns0:ID[@ns0:type='Customer_Reference_ID']")
      ).to eq supplier.salesforce_id
    end

    it 'sets From_Date with the date the Submission is being made against' do
      expect(text_at_xpath('//ns0:From_Date')).to eq task.period_date.to_s
    end

    it 'sets Customer_PO_Number with the Submission’s purchase order number' do
      expect(text_at_xpath('//ns0:Customer_PO_Number')).to eq submission.purchase_order_number
    end

    it 'sets Memo with the Submission’s ID' do
      expect(text_at_xpath('//ns0:Memo')).to eq "Submission ID: #{submission.id}"
    end

    it 'sets Note_Data with the name of the user who submitted the correction submission' do
      expect(text_at_xpath('//ns0:Note_Data//ns0:Note_Content')).to eq 'ForenameR SurnameR'
    end

    it 'sets the invoice adjustment as submitted' do
      expect(text_at_xpath('//ns0:Business_Process_Parameters/ns0:Auto_Complete')).to eq 'true'
      expect(text_at_xpath('//ns0:Submit')).to eq 'true'
    end

    describe '//Customer_Invoice_Line_Replacement_Data' do
      it 'sets Line_Item_Description with a description of the charge' do
        expect(
          text_at_xpath('//ns0:Customer_Invoice_Line_Replacement_Data//ns0:Line_Item_Description')
        ).to eq 'Reversal of invoice for December 2018 management charge'
      end

      it 'sets Analytical_Amount as the negative value of the total spend for the submission' do
        expect(text_at_xpath('//ns0:Customer_Invoice_Line_Replacement_Data//ns0:Analytical_Amount')).to eq '-20.00'
      end

      it 'sets Extended_Amount as the absolute value of the management charge for the submission' do
        expect(text_at_xpath('//ns0:Customer_Invoice_Line_Replacement_Data//ns0:Extended_Amount')).to eq '0.20'
      end

      it 'sets a Worktags_Reference//ID with the framework short name identified as Custom_Organization_Reference_ID' do
        expect(
          text_at_xpath("//ns0:Worktags_Reference//ns0:ID[@ns0:type='Custom_Organization_Reference_ID']")
        ).to eq framework.short_name
      end

      it 'sets Revenue_Category_Reference//ID as the revenue category Workday ID for the Framework' do
        expect(
          text_at_xpath("//ns0:Revenue_Category_Reference//ns0:ID[@ns0:type='Revenue_Category_ID']")
        ).to eq 'Revenue_Category_WID'
      end

      it 'sets Tax_Code_Reference//ID as the tax code Workday ID for the Framework' do
        expect(
          text_at_xpath("//ns0:Tax_Code_Reference//ns0:ID[@ns0:type='Tax_Code_ID']")
        ).to eq 'GBC20'
      end
    end

    def text_at_xpath(xpath)
      Nokogiri::XML(request.content).at_xpath(xpath).text
    end
  end

  describe '#perform' do
    let!(:stub) do
      stub_request(:post, request.url)
        .with(body: request.content)
        .to_return(status: 200, body: File.read(Rails.root.join('spec', 'fixtures', response)))
    end

    describe 'when successful' do
      let(:response) { 'created_invoice_adjustment_response.xml' }

      it 'makes the POST request to the Workday SOAP endpoint' do
        request.perform
        expect(stub).to have_been_requested
      end

      it 'it returns the ID for the invoice' do
        expect(request.perform).to eq('2a743abbf5e3819a6451179ed62d1c06')
      end
    end

    describe 'when there is a fault returned by workday' do
      let(:response) { 'workday_auth_failure.xml' }

      it 'raises an exception with the fault reason as the message' do
        expect { request.perform }.to raise_error(Workday::Fault, 'invalid username or password')
      end
    end
  end
end
