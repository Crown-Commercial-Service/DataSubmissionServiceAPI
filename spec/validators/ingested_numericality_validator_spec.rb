require 'rails_helper'

RSpec.describe IngestedNumericalityValidator do
  let(:sheet_class) do
    Class.new(Framework::Sheet) do
      extend ActiveModel::Naming

      def self.name
        'Validator'
      end

      field 'test', :string, ingested_numericality: true
    end
  end

  it 'validates integers' do
    [-42, 0, 1234].each do |valid_integer|
      instance = sheet_class.new_from_params('test' => valid_integer)

      expect(instance).to be_valid
    end
  end

  it 'validates floats' do
    [-1.23, 0.0, 99.99].each do |valid_float|
      instance = sheet_class.new_from_params('test' => valid_float)

      expect(instance).to be_valid
    end
  end

  it 'validates zero-like values' do
    ['N/A', '-', ' not applicable '].each do |valid_zero_like|
      instance = sheet_class.new_from_params('test' => valid_zero_like)

      expect(instance).to be_valid
    end
  end

  it 'does not validate values that are not numbers' do
    instance = sheet_class.new_from_params('test' => 'Bob')

    expect(instance).not_to be_valid
    expect(instance.errors['test'].first).to eq 'is not a number'
  end
end
