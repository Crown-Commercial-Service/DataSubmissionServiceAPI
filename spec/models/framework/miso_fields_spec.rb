require 'rails_helper'

RSpec.describe Framework::MisoFields do
  let(:framework_short_name) { 'RM3787' }

  let(:miso_fields) { Framework::MisoFields.new(framework_short_name) }

  describe '#order_fields' do
    subject(:order_fields) { miso_fields.order_fields }

    context 'the framework has some rows in the file (Finance)' do
      it 'returns only order fields' do
        expect(order_fields.length).to be > 10
        expect(order_fields).to all(satisfy { |row| row['FrameworkNumber'] == framework_short_name })
        expect(order_fields).to all(satisfy { |row| row['DestinationTable'] == 'Orders' })
      end
    end

    context 'there are no order rows' do
      context 'because there are no rows for the framework' do
        let(:framework_short_name) { 'GEOFFREY_HAYES' }
        it 'tells us so with an ArgumentError' do
          expect { miso_fields.order_fields }.to raise_error(
            ArgumentError, /No fields for framework GEOFFREY_HAYES found in/
          )
        end
      end
      context 'because this framework exists but does not do orders' do
        let(:framework_short_name) { 'CM/OSG/05/3565' }
        it { is_expected.to be_empty }
      end
    end
  end

  describe '#invoice_fields' do
    subject(:invoice_fields) { miso_fields.invoice_fields }

    it 'returns only invoice fields' do
      expect(invoice_fields.length).to be > 10
      expect(invoice_fields).to all(satisfy { |row| row['FrameworkNumber'] == framework_short_name })
      expect(invoice_fields).to all(satisfy { |row| row['DestinationTable'] == 'Invoices' })
    end

    context 'the framework is not found' do
      let(:framework_short_name) { 'CARLOS_EZQUERRA' }
      it 'tells us so with an ArgumentError' do
        expect { miso_fields.invoice_fields }.to raise_error(
          ArgumentError, /No fields for framework CARLOS_EZQUERRA found in/
        )
      end
    end
  end

  describe '#framework_name' do
    subject { miso_fields.framework_name }
    it { is_expected.to eql('Finance & Complex Legal Services') }
  end

  describe '#invoice_total_value_field' do
    subject(:invoice_total_value_field) { miso_fields.invoice_total_value_field }

    it 'returns that field' do
      expect(invoice_total_value_field).to eql('Total Cost (ex VAT)')
    end

    context 'the invoice total field is unmapped' do
      before do
        # throw a nil spanner in the ExportsTo field
        row = miso_fields.invoice_fields.find { |f| f['ExportsTo'] == 'InvoiceValue' }
        row['ExportsTo'] = nil
      end

      it 'raises an ArgumentError' do
        expect do
          miso_fields.invoice_total_value_field
        end.to raise_error(ArgumentError, "no InvoiceValue field found for framework 'RM3787'")
      end
    end
  end

  describe '#order_total_value_field' do
    subject(:order_total_value_field) { miso_fields.order_total_value_field }

    it 'returns that field' do
      expect(order_total_value_field).to eql('Expected Total Order Value')
    end

    context 'the order total field is unmapped' do
      before do
        # throw a nil spanner in the ExportsTo field
        row = miso_fields.order_fields.find { |f| f['ExportsTo'] == 'ContractValue' }
        row['ExportsTo'] = nil
      end

      it 'raises an ArgumentError' do
        expect do
          miso_fields.order_total_value_field
        end.to raise_error(ArgumentError, "no ContractValue field found for framework 'RM3787'")
      end
    end
  end
end
