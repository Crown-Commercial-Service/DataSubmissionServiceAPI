require_dependency 'framework'

require 'active_model/introspector'

class Framework
  module Definition
    ##
    # Create a Framework::Definition derivative given a
    # framework_short_name. See USAGE
    class DebugGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      def create_framework_definition_debug_file
        template(
          'framework_definition_debug.rb.erb',
          "tmp/#{sanitised_framework_short_name}.rb"
        )
      end

      private

      def sanitised_framework_short_name
        name.tr('/.', '_')
      end

      def framework_short_name
        name
      end

      def definition
        @definition ||= Framework::Definition::Language[framework_short_name]
      end

      def management_charge
        definition.management_charge
      end

      def framework_name
        definition.framework_name
      end

      def invoice_introspector
        @invoice_introspector ||= ActiveModel::Introspector.new(definition::Invoice)
      end

      def contract_introspector
        @contract_introspector ||= ActiveModel::Introspector.new(definition::Order)
      end

      def invoice_fields
        definition.const_defined?(:Invoice) ? invoice_introspector.fields : []
      end

      def invoice_total_value_field
        invoice_introspector.fields.find { |f| f.exports_to == 'InvoiceValue' }
      end

      def order_total_value_field
        contract_introspector.fields.find { |f| f.exports_to == 'ContractValue' }
      end

      def order_fields
        definition.const_defined?(:Order) ? contract_introspector.fields : []
      end

      def modernize_hash(h)
        return nil if h.empty?

        h.to_s
          .sub(/^{/, '')                     # Remove start and
          .sub(/}$/, '')                     # end braces
          .gsub(/(:(\w+)\s?=>\s?)/, "\\2: ") # Modernize from :a => :b -> a: :b
          .gsub(/{/, '{ ')                   # Add spaces in all
          .gsub(/}/, ' }')                   # the tight braces
      end

      def lookups
        definition.const_defined?(:Invoice) ?
          definition::Invoice.lookups :
          definition::Order.lookups
      end
    end
  end
end
