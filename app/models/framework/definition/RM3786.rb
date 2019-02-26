class Framework
  module Definition
    class RM3786 < Base
      framework_short_name 'RM3786'
      framework_name       'General Legal Advice Services'

      management_charge_rate BigDecimal('1.5')

      SERVICE_TYPE_VALUES = [
        'Core',
        'Non-core',
        'Mixture'
      ].freeze

      CORE_SPECIALISMS = [
        'Public Law',
        'Contracts',
        'Competition Law',
        'Construction Law',
        'Corporate Law',
        'Dispute Resolution',
        'Employment Law',
        'EU Law',
        'Information Law including Data Protection Law',
        'Information Technology Law',
        'Intellectual Property Law',
        'Litigation',
        'Non-complex Finance',
        'Outsourcing',
        'Partnerwhip Law',
        'Partnership Law',
        'Pensions Law',
        'Planning Law',
        'Projects/PFI/PPP',
        'Public Procurement Law',
        'Real Estate and Real Estate Finance',
        'Restructuring/Insolvency',
        'Tax Law',
        'Environmental Law',
      ].freeze

      NON_CORE_SPECIALISMS = [
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
        'Public International Law'
      ].freeze

      PRIMARY_SPECIALISM_VALUES = (
        CORE_SPECIALISMS +
        NON_CORE_SPECIALISMS
      ).freeze

      MAPPING = {
        'Service Type' => {
          'core' => CORE_SPECIALISMS,
          'non-core' => NON_CORE_SPECIALISMS,
          'mixture' => PRIMARY_SPECIALISM_VALUES,
        }
      }.freeze

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

      CALL_OFF_MANAGING_ENTITY_VALUES = [
        'CCS',
        'Central Government Department',
        '3rd Party Contracting Partner'
      ].freeze

      class Invoice < EntryData
        total_value_field 'Total Cost (ex VAT)'

        field 'Tier Number', :string, exports_to: 'LotNumber', presence: true, lot_in_agreement: true
        field 'Supplier Reference Number', :string, exports_to: 'SupplierReferenceNumber'
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Organisation Name', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Post Code', :string, exports_to: 'CustomerPostCode'
        field 'Customer Invoice Date', :string, exports_to: 'InvoiceDate', ingested_date: true
        field 'Customer Invoice Number', :string, exports_to: 'InvoiceNumber', presence: true
        field 'Service Type', :string, exports_to: 'ProductGroup', presence: true, case_insensitive_inclusion: { in: SERVICE_TYPE_VALUES }
        field 'Primary Specialism', :string, exports_to: 'ProductDescription', presence: true, dependent_field_inclusion: { parent: 'Service Type', in: MAPPING }
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
        field 'Pro-Bono Price per Unit', :string, exports_to: 'Additional1', ingested_numericality: true
        field 'Pro-Bono Quantity', :string, exports_to: 'Additional2', ingested_numericality: true
        field 'Pro-Bono Total Value', :string, exports_to: 'Additional3', ingested_numericality: true
        field 'Sub-Contractor Name (If Applicable)', :string, exports_to: 'Additional4', presence: true
      end

      class Order < EntryData
        total_value_field 'Expected Total Order Value'

        field 'Contract Start Date', :string, exports_to: 'ContractStartDate'
        field 'Contract End Date', :string, exports_to: 'ContractEndDate'
        field 'Award Procedure', :string, exports_to: 'ContractAwardChannel', case_insensitive_inclusion: { in: ['Further Competition', 'Direct Award'] }
        field 'Expected Total Order Value', :string, exports_to: 'ContractValue'
        field 'Sub-Contractor Name', :string, exports_to: 'Additional1'
        field 'Lead Counsel / Matter Owner', :string, exports_to: 'Additional7'
        field 'Call Off Managing Entity', :string, exports_to: 'Additional3', case_insensitive_inclusion: { in: CALL_OFF_MANAGING_ENTITY_VALUES }
        field 'Pro-bono work included? (Y/N)', :string, exports_to: 'Additional4', case_insensitive_inclusion: { in: %w[Y N], message: "must be 'Y' or 'N'" }
        field 'Tier Number', :string, exports_to: 'LotNumber', presence: true, lot_in_agreement: true
        field 'Supplier Reference Number', :string, exports_to: 'SupplierReferenceNumber'
        field 'Customer URN', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Organisation Name', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Post Code', :string, exports_to: 'CustomerPostCode'
        field 'Matter Name', :string, exports_to: 'CustomerReferenceNumber', presence: true
        field 'Matter Description', :string, exports_to: 'ProductDescription'
        field 'Expected Pro-Bono value', :string, exports_to: 'Additional5'
        field 'Expression Of Interest Used (Y/N)', :string, exports_to: 'Additional2'
        field 'Customer Response Time', :string, exports_to: 'Additional6'
      end
    end
  end
end
