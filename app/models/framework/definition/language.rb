require 'framework/definition/AST/creator'

class Framework
  module Definition
    class Language
      def self.generate_framework_definition(source)
        cst = Framework::Definition::Parser.new.parse(source)
        ast = Framework::Definition::AST::Creator.new.apply(cst)

        Class.new(Framework::Definition::Base) do
          framework_short_name ast.fetch(:framework_short_name)
          framework_name ast.fetch(:framework_name)
          management_charge_rate ast.dig(:management_charge, :flat_rate)
        end.tap do |klass|
          invoice_fields_class = Class.new(Framework::EntryData) do
            _total_value_def = ast[:invoice_fields].find { |f| f[:field] == 'TotalValue' }
            total_value_field _total_value_def[:from]

            ast[:invoice_fields].each do |field_def|
              _options = { presence: true }.tap do |options|
                options[:exports_to] = field_def[:field]
                options[:ingested_numericality] = true if DataWarehouse::KnownFields[field_def[:field]] == :decimal
              end.compact

              field field_def[:from], _options
            end
          end
          klass.const_set('Invoice', invoice_fields_class)
        end
      end
    end
  end
end
