class Framework
  module Definition
    class Transpiler
      attr_reader :ast

      def initialize(ast)
        @ast = ast
      end

      def transpile
        ast = @ast # method-local binding required for Class.new blocks

        Class.new(Framework::Definition::Base) do
          framework_name       ast[:framework_name]
          framework_short_name ast[:framework_short_name]
          management_charge    ManagementChargeCalculator::FlatRate.new(
            percentage: ast.dig(:management_charge, :flat_rate)
          )
        end.tap do |klass|
          klass.const_set('Invoice', invoice_fields_class)
        end
      end

      def invoice_fields_class
        ast = @ast

        Class.new(Framework::EntryData) do
          define_singleton_method :model_name do
            ActiveModel::Name.new(self, nil, 'Invoice')
          end

          _total_value_field = AST::Field.by_name(
            ast[:invoice_fields], 'InvoiceValue'
          )
          total_value_field _total_value_field.sheet_name

          lookups ast[:lookups]

          ast[:invoice_fields].each do |field_def|
            field = AST::Field.new(field_def)
            # Always use a case_insensitive_inclusion validator if
            # there's a lookup with the same name as the field
            lookup_values = ast.dig(:lookups, field.lookup_name)
            field field.sheet_name, field.activemodel_type, field.options(lookup_values)
          end
        end
      end
    end
  end
end
