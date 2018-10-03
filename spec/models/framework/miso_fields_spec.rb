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
end
