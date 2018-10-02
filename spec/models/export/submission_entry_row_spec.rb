require 'rails_helper'

RSpec.describe Export::SubmissionEntryRow do
  describe '#value_for' do
    let(:row) { Export::SubmissionEntryRow.new(entry) }

    subject(:value) { row.value_for(field) }

    context 'An invoice entry for RM3786' do
      let(:entry) do
        double 'SubmissionEntry',
               _framework_short_name: 'RM3786', entry_type: 'invoice',
               data: attributes_for(:submission_entry, :legal_framework_invoice_data).fetch(:data)
      end

      context 'the requested export field does not exist' do
        let(:field) { 'DoesNotExist' }

        context 'and no default is given' do
          it { is_expected.to eql('#NOTINDATA') }
        end

        context 'and a default is given' do
          subject { row.value_for(field, default: 'some_default') }
          it { is_expected.to eql('some_default') }
        end
      end

      context 'the requested export field is in the data' do
        let(:field) { 'LotNumber' }

        it 'gets the value from the framework-specific data column' do
          expect(value).to eql(entry.data['Tier Number'])
        end
      end
    end
  end
end
