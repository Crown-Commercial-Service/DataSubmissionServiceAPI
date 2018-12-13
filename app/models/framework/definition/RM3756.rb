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

      class Invoice < EntryData
        total_value_field 'Total Cost (ex VAT)'

        field 'Tier Number', :string, exports_to: 'LotNumber', presence: true, lot_in_agreement: true
        field 'Supplier Reference Number', :string, exports_to: 'SupplierReferenceNumber', presence: true
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Organisation Name', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Post Code', :string, exports_to: 'CustomerPostCode', presence: true
        field 'Customer Invoice Date', :string, exports_to: 'InvoiceDate', ingested_date: true
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber', presence: true
        field 'Service Type', :string, exports_to: 'ProductGroup', presence: true, case_insensitive_inclusion: { in: SERVICE_TYPE_VALUES }
        field 'Primary Specialism', :string, exports_to: 'ProductDescription', presence: true, case_insensitive_inclusion: { in: PRIMARY_SPECIALISM_VALUES, message: 'must match the selected service type. For a list of service types and specialisms, check the lookups tab in the template.' }
        field 'Practitioner Grade', :string, exports_to: 'ProductSubClass', presence: true, case_insensitive_inclusion: { in: PRACTITIONER_GRADE_VALUES }
        field 'UNSPSC', :string, exports_to: 'UNSPSC', ingested_numericality: { only_integer: true }
        field 'Unit of Purchase', :string, exports_to: 'UnitType', presence: true, case_insensitive_inclusion: { in: UNIT_OF_PURCHASE_VALUES }
        field 'Price per Unit', :string, exports_to: 'UnitPrice', ingested_numericality: true
        field 'Quantity', :string, exports_to: 'UnitQuantity', ingested_numericality: true
        field 'Total Cost (ex VAT)', :string, exports_to: 'InvoiceValue', ingested_numericality: true
        field 'VAT Amount Charged', :string, exports_to: 'VATCharged', ingested_numericality: true
        field 'Cost Centre', :string
        field 'Contract Number', :string
        field 'Matter Name', :string, exports_to: 'CustomerReferenceNumber', presence: true
        field 'Pricing Mechanism', :string, exports_to: 'Additional5', presence: true, case_insensitive_inclusion: { in: PRICING_MECHANISM_VALUES }
        # field 'Award Procedure', :string, exports_to: 'Additional6', presence: true
        field 'Pro-Bono Price per Unit', :string, exports_to: 'Additional1', ingested_numericality: true
        field 'Pro-Bono Quantity', :string, exports_to: 'Additional2', ingested_numericality: true
        field 'Pro-Bono Total Value', :string, exports_to: 'Additional3', ingested_numericality: true
        field 'Sub-Contractor Name (If Applicable)', :string, exports_to: 'Additional4', presence: true
      end

      class Order < EntryData
        total_value_field 'Expected Total Order Value'

        field 'Tier Number', :string, exports_to: 'LotNumber', presence: true, lot_in_agreement: true
        field 'Supplier Reference Number', :string, exports_to: 'SupplierReferenceNumber', presence: true
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Organisation Name', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Post Code', :string, exports_to: 'CustomerPostCode', presence: true
        field 'Matter Name', :string, exports_to: 'CustomerReferenceNumber', presence: true
        field 'Matter Description', :string, exports_to: 'ProductDescription', presence: true
        field 'Contract Start Date', :string, exports_to: 'ContractStartDate', ingested_date: true, presence: true
        field 'Contract End Date', :string, exports_to: 'ContractEndDate', ingested_date: true, presence: true
        field 'Award Procedure', :string, exports_to: 'ContractAwardChannel', presence: true, case_insensitive_inclusion: { in: ['Further Competition', 'Direct Award'] }
        field 'Expected Total Order Value', :string, exports_to: 'ContractValue', ingested_numericality: true, presence: true
        field 'Sub-Contractor Name', :string, exports_to: 'Additional1', presence: true
        field 'Expression Of Interest Used (Y/N)', :string, exports_to: 'Additional2', presence: true
        field 'Customer Response Time', :string, exports_to: 'Additional6', presence: true
        field 'Call Off Managing Entity', :string, exports_to: 'Additional3', presence: true
        field 'Pro-bono work included? (Y/N)', :string, exports_to: 'Additional4', presence: true
        field 'Expected Pro-Bono value', :string, exports_to: 'Additional5', presence: true, ingested_numericality: true
      end
    end
  end
end
