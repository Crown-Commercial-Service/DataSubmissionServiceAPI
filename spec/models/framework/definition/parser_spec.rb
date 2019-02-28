require 'rails_helper'
require 'framework/definition/parser'

RSpec.describe Framework::Definition::Parser do
  subject(:parser) { Framework::Definition::Parser.new }
  let(:framework_definition) do
    <<~FDL
      Framework CM/05/3769 {
        Name 'Laundry Services - Wave 2'
        ManagementCharge 0%

        InvoiceFields {
          TotalValue from 'Total Spend'
          CustomerPostCode from 'Customer Postcode'

          String Additional1 from 'Manufacturers Product Code'
        }
      }
    FDL
  end

  describe '#framework_definition' do
    it { is_expected.to parse(framework_definition) }
  end

  describe '#framework_identifier' do
    subject { parser.framework_identifier }

    it { is_expected.to parse('CM/OSG/05/3565').as(string: 'CM/OSG/05/3565') }
    it { is_expected.to parse('RM3710').as(string: 'RM3710') }
    it { is_expected.not_to parse('foobar') }
  end

  describe '#framework_name' do
    subject { parser.framework_name }

    it {
      is_expected.to parse("Name 'Laundry Services - Wave 2'").as(
        framework_name: { string: 'Laundry Services - Wave 2' }
      )
    }
  end

  describe '#percentage' do
    subject { parser.percentage }

    it { is_expected.to parse('0%') }
    it { is_expected.to parse('0.0%') }
  end

  describe '#management_charge' do
    subject { parser.management_charge }

    context 'flat rate' do
      it {
        is_expected.to parse('ManagementCharge 0.0%').as(
          management_charge: { flat_rate: { decimal: '0.0' } }
        )
      }
    end
  end

  describe '#known_field' do
    subject { parser.known_field }

    it {
      is_expected.to parse("TotalValue from 'Total Spend'").as(
        field: 'TotalValue', from: { string: 'Total Spend' }
      )
    }
  end

  describe '#additional_field' do
    subject { parser.additional_field }

    it {
      is_expected.to parse("String Additional1 from 'Manufacturers Product Code'").as(
        type: 'String', field: 'Additional1', from: { string: 'Manufacturers Product Code' }
      )
    }
  end

  describe '#invoice_fields' do
    subject(:rule) { parser.invoice_fields }

    let(:fields) do
      <<~FDL.strip
        InvoiceFields {
          TotalValue from 'Total Spend'
          optional ProductCode from 'Item Code'

          String Additional1 from 'Manufacturers Product Code'

          optional String from 'Cost Centre'
        }
      FDL
    end

    it 'has one known field, one optional known field, one Additional field and one optional unknown field' do
      expect(rule).to parse(fields).as(
        invoice_fields: [
          { field: 'TotalValue', from: { string: 'Total Spend' } },
          { optional: 'optional', field: 'ProductCode', from: { string: 'Item Code' } },
          { type: 'String', field: 'Additional1', from: { string: 'Manufacturers Product Code' } },
          { optional: 'optional', type: 'String', from: { string: 'Cost Centre' } }
        ]
      )
    end
  end
end
