class Framework
  module Definition
    class RM3756 < Base
      framework_short_name 'RM3756'
      framework_name       'Rail Legal Services'

      management_charge_rate BigDecimal('1.5')

      SERVICE_TYPE_VALUES = [
        'Core',
        'Non-core',
        'Mixture'
      ].freeze

      PRIMARY_SPECIALISM_VALUES = [
        'Regulatory Law',
        'Company, Commercial and Contract Law',
        'Public procurement law',
        'EU Law',
        'International Law',
        'Competition Law',
        'Dispute Resolution and Litigation Law',
        'Employment Law',
        'Environmental Law',
        'Health and Safety Law',
        'Information Law including Data Protection Law',
        'Information Technology Law',
        'Intellectual Property Law',
        'Pensions Law',
        'Real Estate Law',
        'Restructuring/Insolvency Law',
        'Tax Law',
        'Insurance Law'
      ].freeze

      PRACTITIONER_GRADE_VALUES = [
        'Partner',
        'Legal Director/Senior Solicitor',
        'Senior Associate',
        'Junior Solicitor',
        'Trainee / Paralegal',
        'Other Grade / Mix'
      ].freeze

      PRICING_MECHANISM_VALUES = [
        'Time and Material',
        'Fixed',
        'Risk-Reward',
        'Gain-Share',
        'Pro-Bono'
      ].freeze

      UNIT_OF_PURCHASE_VALUES = [
        'Hourly',
        'Daily',
        'Monthly',
        'Fixed Price'
      ].freeze

      class Invoice < Sheet
        total_value_field 'Total Cost (ex VAT)'

        field 'Tier Number', :string, exports_to: 'LotNumber', presence: true, inclusion: { in: %w[1 2] }
        field 'Supplier Reference Number', :string, exports_to: 'SupplierReferenceNumber', presence: true
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Organisation Name', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Post Code', :string, exports_to: 'CustomerPostCode', presence: true
        field 'Customer Invoice Date', :string, exports_to: 'InvoiceDate', ingested_date: true
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber', presence: true
        field 'Service Type', :string, exports_to: 'ProductGroup', presence: true, case_insensitive_inclusion: { in: SERVICE_TYPE_VALUES }
        field 'Primary Specialism', :string, exports_to: 'ProductDescription', presence: true, case_insensitive_inclusion: { in: PRIMARY_SPECIALISM_VALUES, message: 'must match the selected service type. For a list of service types and specialisms, check the lookups tab in the template.' }
        field 'Practitioner Grade', :string, exports_to: 'ProductSubClass', presence: true, case_insensitive_inclusion: { in: PRACTITIONER_GRADE_VALUES }
        field 'UNSPSC', :integer, exports_to: 'UNSPSC', numericality: { only_integer: true }
        field 'Unit of Purchase', :string, exports_to: 'UnitType', presence: true, case_insensitive_inclusion: { in: UNIT_OF_PURCHASE_VALUES }
        field 'Price per Unit', :decimal, exports_to: 'UnitPrice', numericality: true
        field 'Quantity', :decimal, exports_to: 'UnitQuantity', numericality: true
        field 'Total Cost (ex VAT)', :decimal, exports_to: 'InvoiceValue', numericality: true
        field 'VAT Amount Charged', :decimal, exports_to: 'VATCharged', numericality: true
        field 'Cost Centre', :string
        field 'Contract Number', :string
        field 'Matter Name', :string, exports_to: 'CustomerReferenceNumber', presence: true
        field 'Pricing Mechanism', :string, exports_to: 'Additional5', presence: true, case_insensitive_inclusion: { in: PRICING_MECHANISM_VALUES }
        # field 'Award Procedure', :string, exports_to: 'Additional6', presence: true
        field 'Pro-Bono Price per Unit', :decimal, exports_to: 'Additional1', numericality: true
        field 'Pro-Bono Quantity', :decimal, exports_to: 'Additional2', numericality: true
        field 'Pro-Bono Total Value', :decimal, exports_to: 'Additional3', numericality: true
        field 'Sub-Contractor Name (If Applicable)', :string, exports_to: 'Additional4', presence: true
      end

      class Order < Sheet
        total_value_field 'Expected Total Order Value'

        field 'Tier Number', :string, exports_to: 'LotNumber', presence: true, inclusion: { in: %w[1 2] }
        field 'Supplier Reference Number', :string, exports_to: 'SupplierReferenceNumber', presence: true
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Organisation Name', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Post Code', :string, exports_to: 'CustomerPostCode', presence: true
        field 'Matter Name', :string, exports_to: 'CustomerReferenceNumber', presence: true
        field 'Matter Description', :string, exports_to: 'ProductDescription'
        field 'Contract Start Date', :string, exports_to: 'ContractStartDate'
        field 'Contract End Date', :string, exports_to: 'ContractEndDate'
        field 'Award Procedure', :string, exports_to: 'ContractAwardChannel', presence: true, case_insensitive_inclusion: { in: ['Further Competition', 'Direct Award'] }
        field 'Expected Total Order Value', :decimal, exports_to: 'ContractValue'
        field 'Sub-Contractor Name', :string, exports_to: 'Additional1'
        field 'Expression Of Interest Used (Y/N)', :string, exports_to: 'Additional2'
        field 'Customer Response Time', :string, exports_to: 'Additional6'
        field 'Call Off Managing Entity', :string, exports_to: 'Additional3'
        field 'Pro-bono work included? (Y/N)', :string, exports_to: 'Additional4'
        field 'Expected Pro-Bono value', :decimal, exports_to: 'Additional5'
      end
    end
  end
end
