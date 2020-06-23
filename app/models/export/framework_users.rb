require 'csv'

module Export
  class FrameworkUsers < ToIO
    HEADER = %w[
      framework_reference
      framework_name
      supplier_salesforce_id
      supplier_name
      supplier_active
      user_email
      user_name
    ].freeze
  end
end
