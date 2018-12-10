require 'rails_helper'

RSpec.describe UrnValidator do
  let(:entry_data_class) do
    Class.new(Framework::EntryData) do
      extend ActiveModel::Naming

      def self.name
        'Validator'
      end

      field 'Customer URN', :string, urn: true
    end
  end

  it 'is valid for URNs that exist' do
    FactoryBot.create(:customer, urn: 12345678)

    entry_data = entry_data_class.new_from_params(
      'Customer URN' => '12345678'
    )

    expect(entry_data).to be_valid
  end

  it 'is invalid for a missing URN' do
    entry_data = entry_data_class.new_from_params(
      'Customer URN' => '88888888'
    )

    expect(entry_data).not_to be_valid
  end
end
