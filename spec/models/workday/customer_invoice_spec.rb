require 'rails_helper'

RSpec.describe Workday::CustomerInvoice do
  subject(:customer_invoice) { Workday::CustomerInvoice.new(submission_invoice.workday_reference) }
  let(:submission) { FactoryBot.create(:submission) }
  let!(:submission_invoice) { FactoryBot.create(:submission_invoice, submission: submission) }

  before do
    allow(Workday).to receive(:tenant).and_return('tenant')
    allow(Workday).to receive(:username).and_return('user')
    allow(Workday).to receive(:api_password).and_return('password')
    stub_request(:get, "https://wd3-impl-services1.workday.com/ccx/service/customreport2/tenant/INT003_ISU/CR_Customer_Invoice_API?Customer_Invoice!WID=#{submission_invoice.workday_reference}")
      .with(headers: { 'Authorization' => 'Basic dXNlcjpwYXNzd29yZA==' })
      .to_return(status: 200, body: File.read(Rails.root.join('spec', 'fixtures', 'customer_invoice.xml')))
  end

  describe '#invoice_details' do
    it 'should return customer invoice details' do
      expect(customer_invoice.invoice_details).to eq(
        invoice_amount: '123.45',
        invoice_number: 'CINV-01234567',
        payment_status: 'Unpaid'
      )
    end

    context 'when the workday API returns a 500 status code' do
      it 'raises an error' do
        stub_request(:get, "https://wd3-impl-services1.workday.com/ccx/service/customreport2/tenant/INT003_ISU/CR_Customer_Invoice_API?Customer_Invoice!WID=#{submission_invoice.workday_reference}")
          .with(headers: { 'Authorization' => 'Basic dXNlcjpwYXNzd29yZA==' })
          .to_return(status: 500, body: '')

        expect { customer_invoice.invoice_details }.to raise_error(Workday::ConnectionError)
      end
    end
  end
end
