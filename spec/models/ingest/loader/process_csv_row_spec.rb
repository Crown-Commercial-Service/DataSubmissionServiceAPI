require 'rails_helper'

RSpec.describe Ingest::Loader::ProcessCsvRow do
  let(:sheet_definition) { Framework::Definition['RM3710'].for_entry_type('invoice') }

  subject(:process_csv_row) { Ingest::Loader::ProcessCsvRow.new(sheet_definition) }

  describe '#process' do
    it 'takes a row of data and coerces it into the correct types' do
      data = {
        'Customer URN' => '12345678'
      }

      result = process_csv_row.process(data)

      expect(result['Customer URN']).to eql 12345678
    end

    context 'with a numeric field' do
      it 'converts to an integer or a float, as appropriate' do
        data = {
          'Lot Number' => '2',
          'Price per Unit (Ex VAT)' => '12.34'
        }

        result = process_csv_row.process(data)

        expect(result['Lot Number']).to be_an(Integer)
        expect(result['Price per Unit (Ex VAT)']).to be_a(Float)
      end
    end

    context 'with a date field' do
      it 'changes an ISO8601 date into dd/mm/yyyy' do
        data = {
          'Customer Invoice Date' => '2020-12-25'
        }

        result = process_csv_row.process(data)

        expect(result['Customer Invoice Date']).to eql '25/12/2020'
      end

      it 'leaves invalid ISO8601 dates alone, so it is caught by a validator' do
        data = {
          'Customer Invoice Date' => '30/02/2019'
        }

        result = process_csv_row.process(data)

        expect(result['Customer Invoice Date']).to eql '30/02/2019'
      end

      it 'leaves bad data alone, so it is caught by a validator' do
        data = {
          'Customer Invoice Date' => 'N/A'
        }

        result = process_csv_row.process(data)

        expect(result['Customer Invoice Date']).to eql 'N/A'
      end

      it 'changes integer date fields into dd/mm/yyyy' do
        data = {
          'Customer Invoice Date' => '44190.0',
        }

        result = process_csv_row.process(data)

        expect(result['Customer Invoice Date']).to eql '25/12/2020'
      end
    end

    context 'with a string' do
      it 'strips whitespace around values' do
        data = {
          'Customer Organisation' => '   Crown Commercial Service   '
        }

        result = process_csv_row.process(data)

        expect(result['Customer Organisation']).to eql 'Crown Commercial Service'
      end
    end

    context 'with a Python boolean' do
      context 'in a non-numeric field' do
        it 'converts True to Y' do
          data = { 'VAT Applicable' => 'True' }

          result = process_csv_row.process(data)

          expect(result['VAT Applicable']).to eql 'Y'
        end

        it 'converts False to N' do
          data = { 'VAT Applicable' => 'False' }

          result = process_csv_row.process(data)

          expect(result['VAT Applicable']).to eql 'N'
        end
      end

      context 'in a numeric field' do
        it 'converts True to 1' do
          data = { 'Quantity' => 'True' }

          result = process_csv_row.process(data)

          expect(result['Quantity']).to eql 1
        end

        it 'converts False to 0' do
          data = { 'Quantity' => 'False' }

          result = process_csv_row.process(data)

          expect(result['Quantity']).to eql 0
        end
      end
    end

    it 'strips out columns that do not appear in the sheet definition for the framework' do
      data = {
        'Lot Number' => 1,
        'Erroneous field' => 'should be removed',
        'Customer URN' => '12345678'
      }

      result = process_csv_row.process(data)

      expect(result).to include('Customer URN', 'Lot Number')
      expect(result).not_to include('Erroneous field')
    end

    it 'strips out columns that contain no data' do
      data = {
        'Customer URN' => '12345678',
        'Customer Name' => ''
      }

      result = process_csv_row.process(data)

      expect(result).to include('Customer URN')
      expect(result).not_to include('Customer Name')
    end
  end
end
