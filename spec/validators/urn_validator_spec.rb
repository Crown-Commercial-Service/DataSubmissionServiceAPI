require 'rails_helper'

RSpec.describe UrnValidator do
  let(:sheet_class) do
    Class.new(Framework::Sheet) do
      extend ActiveModel::Naming

      def self.name
        'Validator'
      end

      field 'Customer URN', :string, urn: true
    end
  end

  it 'is valid for URNs that exist' do
    FactoryBot.create(:customer, urn: 12345678)

    sheet = sheet_class.new_from_params(
      'Customer URN' => 12345678
    )

    expect(sheet).to be_valid
  end

  it 'is invalid for a missing URN' do
    sheet = sheet_class.new_from_params(
      'Customer URN' => 88888888
    )

    expect(sheet).not_to be_valid
  end
end
