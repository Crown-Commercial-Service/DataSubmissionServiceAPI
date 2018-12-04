require 'rails_helper'

RSpec.describe IngestedDateValidator do
  context 'validating a field' do
    let(:sheet_class) do
      Class.new(Framework::Sheet) do
        extend ActiveModel::Naming

        def self.name
          'Validator'
        end

        field 'An Ingested Date', :string, ingested_date: true
      end
    end

    it 'validates DD/MM/YYYY date strings' do
      ['12/10/2018', '1/1/2018', '21/9/2017'].each do |valid_date_string|
        instance = sheet_class.new_from_params('An Ingested Date' => valid_date_string)
        expect(instance).to be_valid
      end
    end

    it 'validates MM/DD/YY date strings' do
      ['9/10/18', '8/1/18', '2/28/17', '3/28/19'].each do |valid_date_string|
        instance = sheet_class.new_from_params('An Ingested Date' => valid_date_string)
        expect(instance).to be_valid
      end
    end

    it 'does not validate correctly formatted but invalid dates' do
      ['28/9/17', '9/21/2017'].each do |invalid_date_string|
        instance = sheet_class.new_from_params('An Ingested Date' => invalid_date_string)
        expect(instance).not_to be_valid
        expect(instance.errors['An Ingested Date'].first).to eq 'must be in the format dd/mm/yyyy'
      end
    end

    it 'does not validate values not formatted as a date' do
      instance = sheet_class.new_from_params('An Ingested Date' => 'Bob')
      expect(instance).not_to be_valid
      expect(instance.errors['An Ingested Date'].first).to eq 'must be in the format dd/mm/yyyy'
    end
  end

  context 'validating an optional field' do
    let(:sheet_class) do
      Class.new(Framework::Sheet) do
        extend ActiveModel::Naming

        def self.name
          'Validator'
        end

        field 'Optional Ingested Date', :string, ingested_date: true, allow_nil: true
      end
    end

    it 'validates a correctly-formatted date string' do
      instance = sheet_class.new_from_params('Optional Ingested Date' => '12/10/2018')
      expect(instance).to be_valid
    end

    it 'validates a blank value' do
      instance = sheet_class.new_from_params('Optional Ingested Date' => nil)
      expect(instance).to be_valid
    end

    it 'mentions that the field is optional in the error message' do
      instance = sheet_class.new_from_params('Optional Ingested Date' => 'Bad Date')
      expect(instance).not_to be_valid
      expect(instance.errors['Optional Ingested Date'].first).to eq 'must be in the format dd/mm/yyyy or left blank'
    end
  end
end
