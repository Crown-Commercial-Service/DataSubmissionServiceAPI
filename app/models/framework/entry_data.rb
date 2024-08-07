class Framework
  ##
  # Define a Sheet for Orders/Invoices on a field-by-field basis
  class EntryData
    include ActiveModel::Attributes
    include ActiveModel::Validations

    attr_reader :entry

    def initialize(entry)
      super()
      @entry = entry
      entry.data.each_pair do |param, value|
        next unless attributes.key?(param)

        send("#{param}=", value)
      end
    end

    def valid_lot_numbers
      entry.submission.agreement.lot_numbers
    end

    class << self
      def export_mappings
        @export_mappings ||= {}
      end

      ##
      # E.g. 'Total Cost (ex VAT)'
      def total_value_field(value = nil)
        @total_value_field ||= value
      end

      def lookups(value = nil)
        @lookups ||= value
      end

      ##
      # Define a field using an ActiveModel-compatible syntax.
      # This is intended to pass through to ActiveModel::Attributes.attribute,
      # but adds options that we need. Right now that's exports_to.
      def field(*args)
        options = args.extract_options!
        field_name = args.first
        exports_to = options.delete(:exports_to)

        export_mappings[exports_to] = field_name if exports_to

        attribute(*args)
        validates(field_name, options) if options.present?
      end
    end
  end
end
