class Framework
  ##
  # Define a Sheet for Orders/Invoices on a field-by-field basis
  class Sheet
    include ActiveModel::Attributes
    include ActiveModel::Validations

    class << self
      def new_from_params(params)
        instance = new

        params.each_pair do |param, value|
          next unless instance.attributes.key?(param)

          instance.send("#{param}=", value)
        end

        instance
      end

      def export_mappings
        @export_mappings ||= {}
      end

      ##
      # E.g. 'Total Cost (ex VAT)'
      def total_value_field(value = nil)
        @total_value_field ||= value
      end

      ##
      # Define a field using an ActiveModel-compatible syntax.
      # This is intended to pass through to ActiveModel::Attributes.attribute,
      # but adds options that we need. Right now that's exports_to.
      def field(*args)
        options = args.extract_options!
        exports_to = options.delete(:exports_to)

        if exports_to
          field_name = args.first
          export_mappings[exports_to] = field_name
        end

        attribute(*args, options)
      end
    end
  end
end
