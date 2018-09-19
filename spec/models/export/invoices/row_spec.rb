require 'rails_helper'

RSpec.describe Export::Invoices::Row do
  let(:invoice_entry) { double 'SubmissionEntry' }

  subject(:row) { Export::Invoices::Row.new(invoice_entry) }

  describe 'Customer fields are currently MISSING' do
    describe '#customer_urn' do
      subject { row.customer_urn }
      it { is_expected.to eql('#MISSING') }
    end
    describe '#customer_name' do
      subject { row.customer_name }
      it { is_expected.to eql('#MISSING') }
    end
    describe '#customer_postcode' do
      subject { row.customer_postcode }
      it { is_expected.to eql('#MISSING') }
    end
  end
end
