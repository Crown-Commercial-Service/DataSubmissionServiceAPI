class Framework
  module Definition
    class RM6060 < Base
      framework_short_name 'RM6060'
      framework_name       'Vehicle Purchase'

      management_charge_rate BigDecimal('0.5')

      LOT_1_SEGMENTS = [
        '4x4/SUV',
        'Executive',
        'Lower Medium',
        'Mini',
        'MPV',
        'Pickup',
        'Specialist Sports',
        'Supermini',
        'Upper Medium',
      ].freeze

      LOT_2_SEGMENTS = [
        'Car Derived Van',
        'LCV',
        'MPV',
        'Pickup',
      ].freeze

      LOT_3_SEGMENTS = [
        'HGV',
      ].freeze

      LOT_4_SEGMENTS = [
        'Motorcycle',
      ].freeze

      LOT_5_SEGMENTS = [
        'Bus',
        'Coach',
      ].freeze

      LOT_6_SEGMENTS = [
        '4x4/SUV/All Terrain vehicle',
        'Executive',
        'Lower Medium',
        'Mini',
        'MPV',
        'Pickup',
        'Specialist Sports',
        'Supermini',
        'Upper Medium',
        'Motorcycle',
      ].freeze

      LOT_7_SEGMENTS = [
        'Car Derived Van',
        'Car Derived Van 4X4 variant',
        'Minibus',
        'LCV',
        'Pickup',
      ].freeze

      MAPPING = {
        'Lot Number' => {
          '1' => LOT_1_SEGMENTS,
          '2' => LOT_2_SEGMENTS,
          '3' => LOT_3_SEGMENTS,
          '4' => LOT_4_SEGMENTS,
          '5' => LOT_5_SEGMENTS,
          '6' => LOT_6_SEGMENTS,
          '7' => LOT_7_SEGMENTS,
        }
      }.freeze

      FUEL_TYPES = [
        'Diesel',
        'Electric',
        'Petrol',
        'Petrol Hybrid',
        'Diesel Hybrid',
      ].freeze

      LEASING_COMPANIES = [
        'ALD Automotive Ltd',
        'Alphabet (GB) Ltd',
        'Arnold Clark Vehicle Management',
        'Arval UK Ltd',
        'BT Fleet',
        'Dawsonrentals Truck and Trailer Ltd',
        'Fleetcare (PSCSM) Ltd',
        'Fraikin Ltd',
        'GMP Drivercare ltd',
        'Hitachi Capital Vehicle Solutions',
        'Inchcape Fleet Solutions',
        'Knowles Associates Total Fleet Management Ltd',
        'LeasePlan UK Ltd',
        'Lex Autolease',
        'Lookers Leasing',
        'Mercedes-Benz Financial Services UK Ltd (Daimler Fleet Management)',
        'Ryder Ltd',
        'Volkswagen Financial Services',
        'Zenith',
        'N/A',
      ].freeze

      class Invoice < EntryData
        total_value_field 'Total Vehicle Cost'

        field 'Customer Organisation Name', :string, exports_to: 'CustomerName', presence: true
        field 'Customer Unique Reference Number (URN)', :integer, exports_to: 'CustomerURN', urn: true
        field 'Customer Invoice/Credit Note Date', :string, exports_to: 'CustomerInvoiceDate', ingested_date: true, presence: true
        field 'Customer Invoice/Credit Note Number', :string, exports_to: 'InvoiceNumber', presence: true
        field 'Lot Number', :string, exports_to: 'LotNumber', presence: true, lot_in_agreement: true
        field 'Vehicle Registration Number', :string, exports_to: 'Additional1', presence: true, length: { maximum: 8 }
        field 'Vehicle CAP Code', :string, exports_to: 'Additional2', presence: true, length: { maximum: 20 }
        field 'Vehicle Make', :string, exports_to: 'Additional3', presence: true
        field 'Vehicle Model', :string, exports_to: 'Additional4', presence: true
        field 'Vehicle Trim/Derivative', :string, exports_to: 'Additional5', presence: true
        field 'Vehicle Segment', :string, exports_to: 'ProductGroup', dependent_field_inclusion: { parent: 'Lot Number', in: MAPPING }
        field 'Fuel Type', :string, exports_to: 'Additional6', presence: true, case_insensitive_inclusion: { in: FUEL_TYPES }
        field 'CO2 Emissions', :string, exports_to: 'Additional7', ingested_numericality: true, allow_nil: true
        field 'MRP Excluding Options', :string, exports_to: 'Additional8', ingested_numericality: true
        field 'Customer Support Terms', :string, exports_to: 'Additional9', ingested_numericality: true
        field 'Additional Support Terms', :string, exports_to: 'Additional10', ingested_numericality: true
        field 'Supplier Price', :string, exports_to: 'Additional11', ingested_numericality: true
        field 'Conversion Cost', :string, exports_to: 'Additional12', ingested_numericality: true
        field 'Parts Cost', :string, exports_to: 'Additional13', ingested_numericality: true
        field 'Total Vehicle Cost', :string, exports_to: 'InvoiceValue', ingested_numericality: true
        field 'Leasing Company', :string, exports_to: 'Additional14', presence: true, case_insensitive_inclusion: { in: LEASING_COMPANIES }
        field 'eAuction Contract Number', :string, exports_to: 'Additional15', presence: true, length: { maximum: 6 }
      end
    end
  end
end
