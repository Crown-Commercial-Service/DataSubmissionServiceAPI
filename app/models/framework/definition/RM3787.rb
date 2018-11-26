class Framework
  module Definition
    class RM3787 < Base
      framework_short_name 'RM3787'
      framework_name       'Finance & Complex Legal Services'

      management_charge_rate BigDecimal('1.5')

      SERVICE_TYPE_VALUES = [
        'Core',
        'Non-core',
        'Mixture'
      ].freeze

      PRICING_MECHANISM_VALUES = [
        'Time and Material',
        'Fixed',
        'Risk-Reward',
        'Gain-Share',
        'Pro-Bono'
      ].freeze

      PRIMARY_SPECIALISM_VALUES = [
        'Corporate Finance',
        'Rescue, Restructuring &  Insolvency',
        'Financial services, market and completion regulation',
        'Investment and Commercial Banking',
        'Insurance and Reinsurance',
        'Investment and Asset Management',
        'Equity Capital Markets',
        'Debt Capital Markets',
        'Asset Finance',
        'High Value or complex transactions and disputes',
        'High value or complex merger and acquisition activity',
        'Projects of exceptional innovation and complexity',
        'Sovereign debt restructuring including international and EU structures and processes',
        'International development/aid funding',
        'International Financial organisations',
        'All aspects of law and practice relating to international trade agreements investments and associated regulations, and to the United Kingdom’s exit from the European Union, in so far as they relate to the above projects',
        'Credit / bond insurance, counter indemnities, alternative risk transfer mechanisms'
      ].freeze

      PRACTITIONER_GRADE_VALUES = [
        'Partner',
        'Legal Director/Senior Solicitor',
        'Senior Associate',
        'Junior Solicitor',
        'Trainee / Paralegal',
        'Other Grade / Mix'
      ].freeze

      UNIT_OF_PURCHASE_VALUES = [
        'Hourly',
        'Daily',
        'Monthly',
        'Fixed Price'
      ].freeze

      CALL_OFF_MANAGING_ENTITY_VALUES = [
        'CCS',
        'Central Government Department',
        '3rd Party Contracting Partner'
      ].freeze

      class Invoice < Sheet
        total_value_field 'Total Cost (ex VAT)'

        field 'Supplier Reference Number', :string, exports_to: 'SupplierReferenceNumber', presence: true
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Organisation Name', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Post Code', :string, exports_to: 'CustomerPostCode', presence: true
        field 'Matter Name', :string, exports_to: 'CustomerReferenceNumber', presence: true
        field 'Customer Invoice Date', :string, exports_to: 'InvoiceDate', ingested_date: true
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber', presence: true
        field 'Service Type', :string, exports_to: 'ProductGroup', presence: true, case_insensitive_inclusion: { in: SERVICE_TYPE_VALUES }
        field 'Primary Specialism', :string, exports_to: 'ProductClass', presence: true, case_insensitive_inclusion: { in: PRIMARY_SPECIALISM_VALUES, message: 'must match the selected service type. For a list of service types and specialisms, check the lookups tab in the template.' }
        field 'Practitioner Grade', :string, exports_to: 'ProductDescription', presence: true, case_insensitive_inclusion: { in: PRACTITIONER_GRADE_VALUES }
        field 'Pricing Mechanism', :string, exports_to: 'ProductSubClass', presence: true, case_insensitive_inclusion: { in: PRICING_MECHANISM_VALUES }
        field 'UNSPSC', :integer, exports_to: 'UNSPSC', numericality: { only_integer: true }
        field 'Unit of Purchase', :string, exports_to: 'UnitType', presence: true, case_insensitive_inclusion: { in: UNIT_OF_PURCHASE_VALUES }
        field 'Price per Unit', :decimal, exports_to: 'UnitPrice', numericality: true
        field 'Quantity', :decimal, exports_to: 'UnitQuantity', numericality: true
        field 'Total Cost (ex VAT)', :decimal, exports_to: 'InvoiceValue', numericality: true
        field 'VAT Amount Charged', :decimal, exports_to: 'VATCharged', numericality: true
        field 'Pro-Bono Price per Unit', :decimal, exports_to: 'Additional1', numericality: true
        field 'Pro-Bono Quantity', :decimal, exports_to: 'Additional2', numericality: true
        field 'Pro-Bono Total Value', :decimal, exports_to: 'Additional3', numericality: true
        field 'Sub-Contractor Name (If Applicable)', :string, exports_to: 'Additional4', presence: true
      end

      class Order < Sheet
        total_value_field 'Expected Total Order Value'

        field 'Supplier Reference Number', :string, exports_to: 'SupplierReferenceNumber', presence: true
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Organisation Name', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Post Code', :string, exports_to: 'CustomerPostcode', presence: true
        field 'Matter Name', :string, exports_to: 'CustomerReferenceNumber', presence: true
        field 'Matter Description', :string, exports_to: 'ProductDescription', presence: true
        field 'Contract Start Date', :string, exports_to: 'ContractStartDate', ingested_date: true
        field 'Contract End Date', :string, exports_to: 'ContractEndDate', ingested_date: true
        field 'Expected Total Order Value', :decimal, exports_to: 'ContractValue', numericality: true
        field 'Sub-Contractor Name', :string, exports_to: 'Additional1', presence: true
        field 'Expression Of Interest Used (Y/N)', :string, exports_to: 'Additional2', presence: true
        field 'Customer Response Time', :string, exports_to: 'Additional6', presence: true
        field 'Call Off Managing Entity', :string, exports_to: 'Additional3', case_insensitive_inclusion: { in: CALL_OFF_MANAGING_ENTITY_VALUES }
        field 'Award Procedure', :string, exports_to: 'ContractAwardChannel', presence: true
        field 'Pro-bono work included? (Y/N)', :string, exports_to: 'Additional4', presence: true
        field 'Expected Pro-Bono value', :decimal, exports_to: 'Additional5', presence: true
      end
    end
  end
end
