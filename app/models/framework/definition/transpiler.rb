class Framework
  module Definition
    class Transpiler
      attr_reader :ast

      def initialize(ast)
        @ast = ast
      end

      def transpile
        # method-local bindings required for Class.new blocks
        ast = @ast
        transpiler = self

        Class.new(Framework::Definition::Base) do
          framework_name       ast[:framework_name]
          framework_short_name ast[:framework_short_name]

          calculator = transpiler.choose_management_charge_calculator(ast[:management_charge])

          management_charge calculator
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
            field = AST::Field.new(field_def, ast.fetch(:lookups, {}))
            # Always use a case_insensitive_inclusion validator if
            # there's a lookup with the same name as the field
            lookup_values = ast.dig(:lookups, field.lookup_name)
            field field.sheet_name, field.activemodel_type, field.options(lookup_values)
          end
        end
      end

      def choose_management_charge_calculator(info)
        if info[:column_based]
          ManagementChargeCalculator::ColumnBased.new(
            varies_by:           info[:column_based][:column_name],
            value_to_percentage: info[:column_based][:value_to_percentage]
          )
        elsif info[:sector_based]
          ManagementChargeCalculator::SectorBased.new(
            central_government:  info[:sector_based][:central_government],
            wider_public_sector: info[:sector_based][:wider_public_sector]
          )
        elsif info[:flat_rate]
          ManagementChargeCalculator::FlatRate.new(
            percentage: info[:flat_rate][:value],
            column:     info[:flat_rate][:column]
          )
        end
      end
    end
  end
end
