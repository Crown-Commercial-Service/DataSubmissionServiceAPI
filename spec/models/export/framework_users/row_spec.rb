require 'rails_helper'
require 'ostruct'

RSpec.describe Export::FrameworkUsers::Row do
  let(:input) do
    OpenStruct.new(
      _framework_reference: 'RM1234.42',
      _framework_name: 'G-Cloud 42',
      _supplier_salesforce_id: 'ACT1234',
      _supplier_name: 'Active Technologies',
      _supplier_active: false,
      _user_name: 'F Beane',
      _user_email: 'fbeane@gmail.com'
    )
  end

  describe '#row_values' do
    it 'maps the projected values to an array' do
      row = Export::FrameworkUsers::Row.new(input, {})

      expect(row.row_values).to match_array(
        [
          'RM1234.42',
          'G-Cloud 42',
          'ACT1234',
          'Active Technologies',
          'N',
          'fbeane@gmail.com',
          'F Beane'
        ]
      )
    end
  end

  describe '#supplier_active' do
    it 'converts true to Y' do
      input[:_supplier_active] = true
      row = Export::FrameworkUsers::Row.new(input, {})

      expect(row.supplier_active).to eql 'Y'
    end

    it 'converts false to N' do
      input[:_supplier_active] = false
      row = Export::FrameworkUsers::Row.new(input, {})

      expect(row.supplier_active).to eql 'N'
    end
  end
end
