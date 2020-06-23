require 'csv'

module Export
  class FrameworkSuppliersLots < ToIO
    HEADER = %w[
      framework_reference
      framework_name
      supplier_salesforce_id
      supplier_name
      supplier_active
      lot_number
    ].freeze
  end
end
