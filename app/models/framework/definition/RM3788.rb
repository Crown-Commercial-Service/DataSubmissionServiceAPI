class Framework
  module Definition
    class RM3788 < Base
      framework_short_name 'RM3788'
      framework_name       'Wider Public Services Legal Services'

      management_charge ManagementChargeCalculator::FlatRate.new(percentage: BigDecimal('1.5'))

      LOT_1_SERVICES = [
        'Social Housing',
        'Child Law',
        'Court of Protection',
        'Education',
        'Planning and Environment',
        'Licensing',
        'Pensions Law',
        'Litigation and Dispute Resolution',
        'Intellectual Property Law',
        'Employment Law',
        'Healthcare',
        'Primary Care',
        'Debt Recovery',
      ].freeze

      LOT_2_SERVICES = [
        'Administrative and Public Law',
        'Banking and Finance',
        'Contracts',
        'Corporate and M and A',
        'Data Protection and Information Law',
        'Employment Law',
        'Information Technology Law',
        'Infrastructure',
        'Information Technology Law',
        'Intellectual Property Law',
        'Litigation and Dispute Resolution',
        'Outsourcing/Insourcing',
        'Partnerships',
        'Pensions Law',
        'Public Procurement Law',
        'Property, Real Estate and Construction',
        'Tax Law',
        'Competition Law',
        'Education Law',
        'Child Law',
        'Energy and Natural Resources',
        'Food, Rural and Environmental Affairs',
        'Franchise Law',
        'Health and Healthcare',
        'Health and Safety',
        'Life Sciences',
        'Public Inquiries and Inquests',
        'Telecommunications',
        'Law of International Trade, Investment and Regulation',
        'Public International Law',
      ].freeze

      LOT_3_SERVICES = [
        'Construction',
        'Property'
      ].freeze

      LOT_4_SERVICES = [
        'Transport Rail'
      ].freeze

      PRICING_MECHANISM_VALUES = [
        'Time and Materials',
        'Pro Bono',
        'Fixed Price',
        'Capped Fee',
        'Risk and Reward',
        'Blended Rates',
        'Other Alternative Fee Arrangements'
      ].freeze

      MAPPING = {
        'Lot Number' => {
          '1' => LOT_1_SERVICES,
          '2a' => LOT_2_SERVICES,
          '2b' => LOT_2_SERVICES,
          '2c' => LOT_2_SERVICES,
          '3' => LOT_3_SERVICES,
          '4' => LOT_4_SERVICES
        }
      }.freeze

      LOT_1_GRADES = [
        'Managing Practitioner',
        'Senior Practitioner',
        'Solicitor/Associate',
        'Legal Support Practitioner/Executive',
        'Risk and Reward'
      ].freeze

      LOT_2_3_4_GRADES = [
        'Partner',
        'Senior Solicitor',
        'Solicitor',
        'Junior Solicitor',
        'Paralegal',
        'Risk and Reward'
      ].freeze

      GRADE_MAPPING = {
        'Lot Number' => {
          '1' => LOT_1_GRADES,
          '2a' => LOT_2_3_4_GRADES,
          '2b' => LOT_2_3_4_GRADES,
          '2c' => LOT_2_3_4_GRADES,
          '3' => LOT_2_3_4_GRADES,
          '4' => LOT_2_3_4_GRADES
        }
      }.freeze

      STANDARD_UNITS = [
        'Per Hour',
        'Per Day',
        'Per Month',
      ].freeze

      OTHER_UNITS = [
        'Per Hour',
        'Per Day',
        'Per Month',
        'Fixed Fee',
      ].freeze

      RISK_UNIT = [
        'Percentage',
      ].freeze

      FIXED_UNIT = [
        'Fixed Fee',
      ].freeze

      PRICING_MAPPING = {
        'Pricing Mechanism' => {
          'Time and Materials' => STANDARD_UNITS,
          'Pro Bono' => STANDARD_UNITS,
          'Fixed Price' => FIXED_UNIT,
          'Capped Fee' => OTHER_UNITS,
          'Risk and Reward' => RISK_UNIT,
          'Blended Rates' => STANDARD_UNITS,
          'Other Alternative Fee Arrangements' => OTHER_UNITS,
        }
      }.freeze

      ORDER_CHANNEL_VALUES = [
        'Direct Award',
        'Further Competition',
      ].freeze

      class Invoice < EntryData
        total_value_field 'Total Cost (ex VAT)'

        field 'Supplier Reference Number', :string, exports_to: 'SupplierReferenceNumber', presence: true
        field 'Customer Organisation Name', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Unique Reference Number (URN)', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Invoice/Credit Note Date', :string, exports_to: 'InvoiceDate', ingested_date: true
        field 'Customer Invoice/Credit Note Number', :string, exports_to: 'InvoiceNumber', presence: true
        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true, lot_in_agreement: true
        field 'Matter Name', :string, exports_to: 'CustomerReferenceNumber', presence: true
        field 'Specialism', :string, exports_to: 'ProductGroup', presence: true, dependent_field_inclusion: { parent: 'Lot Number', in: MAPPING }
        field 'Pricing Mechanism', :string, exports_to: 'ProductClass', presence: true, case_insensitive_inclusion: { in: PRICING_MECHANISM_VALUES }
        field 'Fee Earner', :string, exports_to: 'ProductSubClas', presence: true, dependent_field_inclusion: { parent: 'Lot Number', in: GRADE_MAPPING }
        field 'Unit of Measure', :string, exports_to: 'UnitType', presence: true, dependent_field_inclusion: { parent: 'Pricing Mechanism', in: PRICING_MAPPING }
        field 'Quantity', :string, exports_to: 'UnitQuantity', ingested_numericality: true
        field 'Price per Unit', :string, exports_to: 'UnitPrice', ingested_numericality: true
        field 'Total Cost (ex VAT)', :string, exports_to: 'InvoiceValue', ingested_numericality: true
        field 'Expenses / Disbursements', :string, exports_to: 'Expenses', ingested_numericality: true
        field 'Pro-Bono Quantity', :string, exports_to: 'Additional2', ingested_numericality: true
        field 'Pro-Bono Price per Unit', :string, exports_to: 'Additional1', ingested_numericality: true
        field 'Pro-Bono Total Value', :string, exports_to: 'Additional3', ingested_numericality: true
      end

      class Order < EntryData
        total_value_field 'Total Contract Value'

        field 'Supplier Reference Number', :string, exports_to: 'SupplierReferenceNumber', presence: true
        field 'Customer Organisation Name', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Unique Refrence Number (URN)', :integer, exports_to: 'CustomerURN', urn: true
        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true, lot_in_agreement: true
        field 'Matter Name', :string, exports_to: 'CustomerReferenceNumber', presence: true
        field 'Matter Description', :string, exports_to: 'ProductDescription', presence: true
        field 'Order Channel', :string, exports_to: 'ContractAwardChannel', case_insensitive_inclusion: { in: ORDER_CHANNEL_VALUES }, presence: true
        field 'Contract Start Date', :string, exports_to: 'ContractStartDate', ingested_date: true
        field 'Contract End Date', :string, exports_to: 'ContractEndDate', ingested_date: true
        field 'Total Contract Value', :string, exports_to: 'ContractValue', ingested_numericality: true
      end
    end
  end
end
