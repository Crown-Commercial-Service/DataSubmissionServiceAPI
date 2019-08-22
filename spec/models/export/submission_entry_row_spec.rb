require 'rails_helper'

RSpec.describe Export::SubmissionEntryRow do
  describe '#value_for' do
    let(:cache) { {} }
    let(:row) { Export::SubmissionEntryRow.new(entry, cache) }

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
          /There is no framework definition for "RM12345"/
        )
      end
    end

    context 'An invoice entry for existing framework RM3786' do
      let(:framework) { create(:framework, :with_fdl, short_name: 'RM3786') }

      let(:entry) do
        double 'SubmissionEntry',
               _framework_short_name: framework.short_name, entry_type: 'invoice',
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

      context 'the framework definition is already in the cache' do
        let(:definition) { FrameworkLoader['RM3786'] }
        let(:cache) { { 'RM3786' => definition } }
        let(:field) { 'LotNumber' }

        it 'uses the definition from the cache and does not create another' do
          expect(definition).to receive(:for_entry_type).and_call_original
          expect(Framework::Definition).not_to receive(:[])

          value
        end
      end

      context 'the framework definition is not already in the cache' do
        let(:field) { 'LotNumber' }

        it 'creates a definition and stores it in the cache' do
          value
        end
      end
    end
  end

  describe '#formatted_date returning dates as ISO8601' do
    let(:row) { Export::SubmissionEntryRow.new(entry, {}) }
    let(:entry) { double 'SubmissionEntry' }

    it 'handles DD/MM/YYYY date strings' do
      expect(row.formatted_date('12/10/2018')).to eq '2018-10-12'
      expect(row.formatted_date('1/1/2018')).to eq '2018-01-01'
      expect(row.formatted_date('21/9/2017')).to eq '2017-09-21'
    end

    it 'returns the input value for non-matching dates' do
      expect(row.formatted_date(nil)).to be_nil
      expect(row.formatted_date('')).to eq ''
    end

    it 'returns the input value for invalid dates' do
      expect(row.formatted_date('13/28/19')).to eq '13/28/19'
    end
  end

  describe '#format_decimal strips non-numeric characters' do
    let(:row) { Export::SubmissionEntryRow.new(entry, {}) }
    let(:entry) { double 'SubmissionEntry' }

    it 'handles integers' do
      expect(row.formatted_decimal(42)).to eql 42
      expect(row.formatted_decimal(-1234)).to eql(-1234)
    end

    it 'handles floats' do
      expect(row.formatted_decimal(42.42)).to eql 42.42
      expect(row.formatted_decimal(-12.34)).to eql(-12.34)
    end

    it 'handles strings containing invalid characters' do
      expect(row.formatted_decimal('  12.34   ')).to eql 12.34
      expect(row.formatted_decimal('€5.12')).to eql 5.12
      expect(row.formatted_decimal('- $10.99')).to eql(-10.99)
      expect(row.formatted_decimal(' 4,321.99 ')).to eql(4321.99)
    end

    it 'handles strings that do not contain a number' do
      expect(row.formatted_decimal(' N/A ')).to eql 0.0
    end
  end
end
