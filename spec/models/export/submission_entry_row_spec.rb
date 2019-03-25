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

  describe '#format_date returning dates as ISO8601' do
    let(:row) { Export::SubmissionEntryRow.new(entry) }
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
    let(:row) { Export::SubmissionEntryRow.new(entry) }
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
