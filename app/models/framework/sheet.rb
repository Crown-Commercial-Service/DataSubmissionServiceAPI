class Framework
  ##
  # Define a Sheet for Orders/Invoices on a field-by-field basis
  class Sheet
    class << self
      def export_mappings
        @export_mappings ||= {}
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

        true # avoid Rubocop guard clause before we can start calling ActiveModel
        # attribute(*args, options) # call ActiveModel for validations
      end
    end
  end
end
