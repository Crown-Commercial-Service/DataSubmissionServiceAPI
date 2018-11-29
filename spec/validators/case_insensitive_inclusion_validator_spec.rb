require 'rails_helper'

RSpec.describe CaseInsensitiveInclusionValidator do
  let(:sheet_class) do
    Class.new(Framework::Sheet) do
      extend ActiveModel::Naming

      def self.name
        'Validator'
      end

      field 'Vat Included', :string, case_insensitive_inclusion: { in: %w[Y N] }
    end
  end

  it 'is valid when value is included in the list of valid values' do
    sheet = sheet_class.new_from_params(
      'Vat Included' => 'Y'
    )

    expect(sheet).to be_valid
  end

  it 'is valid for values that differ in case from the list of valid values' do
    sheet = sheet_class.new_from_params(
      'Vat Included' => 'n'
    )

    expect(sheet).to be_valid
  end

  it 'is invalid for values that are not in the list of valid values' do
    sheet = sheet_class.new_from_params(
      'Vat Included' => 'x'
    )

    expect(sheet).not_to be_valid
  end

  it 'is valid for empty values' do
    sheet = sheet_class.new_from_params(
      'Vat Included' => nil
    )

    expect(sheet).to be_valid
  end
end
