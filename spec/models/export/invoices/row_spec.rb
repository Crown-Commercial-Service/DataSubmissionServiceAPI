require 'rails_helper'

RSpec.describe Export::Invoices::Row do
  subject(:row) { Export::Invoices::Row.new(invoice_entry) }

  context 'General legal framework RM3786' do
    let(:invoice_entry) do
      double 'SubmissionEntry',
             _framework_short_name: 'RM3786',
             entry_type: 'invoice',
             data: attributes_for(:submission_entry, :legal_framework_invoice_data).fetch(:data)
    end

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
      describe '#invoice_value' do
        subject { row.invoice_value }
        it { is_expected.to eql(invoice_entry.data['Total Cost (ex VAT)']) }
      end
      describe '#supplier_reference_number' do
        subject { row.supplier_reference_number }
        it { is_expected.to eql(invoice_entry.data['Supplier Reference Number']) }
      end
      describe '#vat_charged' do
        subject { row.vat_charged }
        it { is_expected.to eql(invoice_entry.data['VAT Amount Charged']) }
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

    describe '#lot_number' do
      subject { row.lot_number }
      it { is_expected.to eql(invoice_entry.data['Tier Number']) }
    end

    describe 'Product fields are not captured in legal frameworks' do
      describe '#product_description' do
        subject { row.product_description }
        it { is_expected.to be_nil }
      end
      describe '#product_group' do
        subject { row.product_group }
        it { is_expected.to be_nil }
      end
      describe '#product_class' do
        subject { row.product_class }
        it { is_expected.to be_nil }
      end
      describe '#product_subclass' do
        subject { row.product_subclass }
        it { is_expected.to be_nil }
      end
      describe '#product_code' do
        subject { row.product_code }
        it { is_expected.to be_nil }
      end
    end

    describe 'Unit* fields' do
      describe '#unit_type' do
        subject { row.unit_type }
        it { is_expected.to eql(invoice_entry.data['Unit of Purchase']) }
      end
      describe '#unit_price' do
        subject { row.unit_price }
        it { is_expected.to eql(invoice_entry.data['Price per Unit']) }
      end
      describe '#unit_quantity' do
        subject { row.unit_quantity }
        it { is_expected.to eql(invoice_entry.data['Quantity']) }
      end
    end

    describe '#expenses' do
      subject { row.expenses }
      it { is_expected.to be_nil }
    end

    describe '#promotion_code' do
      subject { row.promotion_code }
      it { is_expected.to be_nil }
    end

    describe 'additional fields' do
      describe 'Additional 1' do
        subject { row.value_for('Additional1') }
        it { is_expected.to eql(invoice_entry.data['Matter Name']) }
      end
      describe 'Additional 2' do
        subject { row.value_for('Additional2') }
        it { is_expected.to eql(invoice_entry.data['Pro-Bono Price per Unit']) }
      end
      describe 'Additional 3' do
        subject { row.value_for('Additional3') }
        it { is_expected.to eql(invoice_entry.data['Pro-Bono Quantity']) }
      end
      describe 'Additional 4' do
        subject { row.value_for('Additional4') }
        it { is_expected.to eql(invoice_entry.data['Pro-Bono Total Value']) }
      end
      describe 'Additional 5' do
        subject { row.value_for('Additional5') }
        it { is_expected.to eql(invoice_entry.data['Sub-Contractor Name (If Applicable)']) }
      end
      describe 'Additional 6' do
        subject { row.value_for('Additional6') }
        it { is_expected.to eql(invoice_entry.data['Pricing Mechanism']) }
      end
    end
  end
end
