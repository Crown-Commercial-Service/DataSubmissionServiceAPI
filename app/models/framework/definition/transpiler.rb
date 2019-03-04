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
        transpiler = self

        Class.new(Framework::EntryData) do
          define_singleton_method :model_name do
            ActiveModel::Name.new(self, nil, 'Invoice')
          end

          _total_value_field = Framework::Definition::AST::FieldPresenter.by_name(
            ast[:invoice_fields], 'TotalValue'
          )
          total_value_field _total_value_field.sheet_name

          ast[:invoice_fields].each do |field_def|
            field = Framework::Definition::AST::FieldPresenter.new(field_def)
            _options = transpiler.send(:options_for_field, field)

            field field.sheet_name, field.activemodel_type, _options
          end
        end
      end

      private

      TYPE_VALIDATIONS = {
        string:  {},
        decimal: { ingested_numericality: true },
        urn:     { urn: true },
        date:    { ingested_date: true },
        yesno:   { case_insensitive_inclusion: { in: %w[Y N], message: "must be 'Y' or 'N'" } }
      }.freeze

      def options_for_field(field)
        { presence: true }.tap do |options|
          options[:exports_to] = field.warehouse_name
          if field.known? # an additional field has a type
            field_type = DataWarehouse::KnownFields[field.warehouse_name]
            options.merge!(TYPE_VALIDATIONS.fetch(field_type))
          end
          if field.optional?
            options.delete(:presence)
            options[:allow_nil] = true if field.validators?
          end
        end.compact
      end
    end
  end
end
