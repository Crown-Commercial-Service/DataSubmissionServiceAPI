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
          _total_value_def = ast[:invoice_fields].find { |f| f[:field] == 'TotalValue' }
          total_value_field _total_value_def[:from]

          ast[:invoice_fields].each do |field_def|
            _options = { presence: true }.tap do |options|
              options[:exports_to] = field_def[:field]
              if field_def[:type].nil? # an additional field has a type
                case DataWarehouse::KnownFields[field_def[:field]]
                when :decimal then options[:ingested_numericality] = true
                when :urn then options[:urn] = true
                when :date then options[:ingested_date] = true
                when :yesno then options[:case_insensitive_inclusion] = { in: %w[Y N], message: "must be 'Y' or 'N'" }
                end
              end
            end.compact

            field field_def[:from], :string, _options
          end
        end
      end
    end
  end
end
