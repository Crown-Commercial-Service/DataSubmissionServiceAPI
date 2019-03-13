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
      it { is_expected.to parse('ManagementCharge 0.0%').as(management_charge: { flat_rate: { decimal: '0.0' } }) }
    end

    context 'column based' do
      let(:source) do
        <<~FDL.strip
          ManagementCharge varies_by 'Spend Code' {
            'Lease Rental' -> 0.5%
            'Damage'       -> 0%
           }
        FDL
      end

      it {
        is_expected.to parse(source).as(
          management_charge: {
            column_based: {
              column_name: { string: 'Spend Code' },
              value_to_percentage: {
                dictionary: [
                  { key: { string: 'Lease Rental' }, value: { decimal: '0.5' } },
                  { key: { string: 'Damage' }, value: { integer: '0' } }
                ]
              }
            }
          }
        )
      }
    end
  end

  describe '#known_field' do
    subject { parser.known_field }

    context 'mandatory field' do
      it {
        is_expected.to parse("InvoiceValue from 'Total Spend'").as(
          field: 'InvoiceValue', from: { string: 'Total Spend' }
        )
      }
    end

    context 'optional field' do
      it {
        is_expected.to parse("optional ProductGroup from 'Service Type'").as(
          optional: 'optional', field: 'ProductGroup', from: { string: 'Service Type' }
        )
      }
    end
  end

  describe '#additional_field' do
    subject { parser.additional_field }

    context 'mandatory field' do
      it {
        is_expected.to parse("String Additional1 from 'Manufacturers Product Code'").as(
          type: 'String', field: 'Additional1', from: { string: 'Manufacturers Product Code' }
        )
      }
    end

    context 'optional field' do
      it {
        is_expected.to parse("optional String Additional1 from 'Manufacturers Product Code'").as(
          optional: 'optional', type: 'String', field: 'Additional1', from: { string: 'Manufacturers Product Code' }
        )
      }
    end
  end

  describe '#unknown_field' do
    subject { parser.unknown_field }

    context 'mandatory field' do
      it {
        is_expected.to parse("String from 'Cost Centre'").as(
          type: 'String', from: { string: 'Cost Centre' }
        )
      }
    end

    context 'optional field' do
      it {
        is_expected.to parse("optional String from 'Cost Centre'").as(
          optional: 'optional', type: 'String', from: { string: 'Cost Centre' }
        )
      }
    end
  end

  describe '#invoice_fields' do
    subject(:rule) { parser.invoice_fields }

    let(:fields) do
      <<~FDL.strip
        InvoiceFields {
          String Additional1 from 'Manufacturers Product Code'
        }
      FDL
    end

    it 'has whatever fields are in the block' do
      expect(rule).to parse(fields).as(
        invoice_fields: [
          { type: 'String', field: 'Additional1', from: { string: 'Manufacturers Product Code' } },
        ]
      )
    end
  end

  describe '#lookups_block' do
    subject(:rule) { parser.lookups_block }

    let(:source) do
      <<~FDL.strip
        Lookups {
          PaymentProfile [
            'Monthly'
            'Quarterly'
          ]

          ServiceType [
            'Type1'
            'Type2'
          ]
        }
      FDL
    end

    it 'parses the lookup fields' do
      expect(rule).to parse(source).as(
        lookups: [
          {
            lookup_name: 'PaymentProfile',
            list: [
              { string: 'Monthly' },
              { string: 'Quarterly' }
            ]
          },
          {
            lookup_name: 'ServiceType',
            list: [
              { string: 'Type1' },
              { string: 'Type2' }
            ]
          }
        ]
      )
    end
  end
end
