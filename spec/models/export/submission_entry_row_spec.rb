require 'rails_helper'

RSpec.describe Export::SubmissionEntryRow do
  describe '#value_for' do
    let(:row) { Export::SubmissionEntryRow.new(entry) }

    subject(:value) { row.value_for(field) }

    context 'An invoice entry for a non-existent framework' do
      let(:entry) do
        double 'SubmissionEntry',
               _framework_short_name: 'RM12345', entry_type: 'invoice'
      end

      it 'tells us what to do about that' do
        expect do
          row.value_for('some_field')
        end.to raise_error(
          Framework::Definition::MissingError,
          /Please run rails g framework:definition "RM12345"/
        )
      end
    end

    context 'An invoice entry for existing framework RM3786' do
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
