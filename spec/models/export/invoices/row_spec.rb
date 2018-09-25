require 'rails_helper'

RSpec.describe Export::Invoices::Row do
  let(:invoice_entry) do
    double 'SubmissionEntry',
           _framework_short_name: 'RM3786',
           data: {
             'UNSPSC' => '80120000',
             'Quantity' => '-0.9',
             'Matter Name' => 'GITIS Terms and Conditions',
             'Tier Number' => '1',
             'Customer URN' => '10012345',
             'Service Type' => 'Core',
             'Price per Unit' => '151.09',
             'Unit of Purchase' => 'Hourly',
             'Pricing Mechanism' => 'Time and Material',
             'Pro-Bono Quantity' => '0.00',
             'Customer Post Code' => 'SW1P 3ZZ',
             'Practitioner Grade' => 'Legal Director/Senior Solicitor',
             'Primary Specialism' => 'Contracts',
             'VAT Amount Charged' => '-27.20',
             'Total Cost (ex VAT)' => '-135.98',
             'Pro-Bono Total Value' => '0.00',
             'Customer Invoice Date' => '5/31/18',
             'Customer Invoice Number' => '3307957',
             'Pro-Bono Price per Unit' => '0.00',
             'Supplier Reference Number' => 'DEP/0008.00032',
             'Customer Organisation Name' => 'Department for Education',
             'Sub-Contractor Name (If Applicable)' => 'N/A'
           }
  end

  subject(:row) { Export::Invoices::Row.new(invoice_entry) }

  describe 'Customer fields' do
    describe '#customer_urn' do
      subject { row.customer_urn }
      it { is_expected.to eql(invoice_entry.data['Customer URN']) }
    end
    describe '#customer_name' do
      subject { row.customer_name }
      it { is_expected.to eql('Department for Education') }
    end
    describe '#customer_postcode' do
      subject { row.customer_postcode }
      it { is_expected.to eql(invoice_entry.data['Customer Post Code']) }
    end
    describe '#customer_reference_number' do
      subject { row.customer_reference_number }

      context 'in legal frameworks' do
        it { is_expected.to be_nil }
      end
    end
  end

  describe 'Invoice fields' do
    describe '#invoice_date' do
      it 'passes through the date without transformation to ISO8601 (this may/should change)' do
        expect(row.invoice_date).to eql(invoice_entry.data['Customer Invoice Date'])
      end
    end
    describe '#invoice_number' do
      subject { row.invoice_number }
      it { is_expected.to eql(invoice_entry.data['Customer Invoice Number']) }
    end
    describe '#supplier_reference_number' do
      subject { row.supplier_reference_number }
      it { is_expected.to eql(invoice_entry.data['Supplier Reference Number']) }
    end
  end

  describe 'what happens when a key is missing in the model’s data' do
    before do
      invoice_entry.data.delete('Customer Post Code')
    end

    it 'substitutes #NOT_IN_DATA' do
      expect(row.customer_postcode).to eql('#NOTINDATA')
    end
  end
end
