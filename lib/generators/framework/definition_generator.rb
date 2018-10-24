require 'csv'
require 'framework' # failure to require this here will result in autoload problems

class Framework
  ##
  # Create a Framework::Definition derivative given a
  # framework_short_name. See USAGE
  class DefinitionGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('templates', __dir__)

    def create_framework_definition_file
      template(
        'framework_definition.rb.erb',
        "app/models/framework/definition/#{sanitised_framework_short_name}.rb"
      )
    end

    private

    def activemodel_data_type(dotnet_data_type)
      {
        'System.Int32' => ':integer',
        'System.String' => ':string',
        'System.Decimal' => ':decimal',
        'System.Date' => ':date',
        'System.Boolean' => ':boolean',
      }.fetch(dotnet_data_type)
    end

    def sanitised_framework_short_name
      name.upcase.tr('/', '_')
    end

    def framework_short_name
      name
    end

    delegate :framework_name, :invoice_fields, :invoice_validations, :order_fields, :order_validations, to: :miso_fields

    def miso_fields
      @miso_fields ||= Framework::MisoFields.new(framework_short_name)
    end

    def quote(field_name)
      field_name.match?(/'/) ? %("#{field_name}") : "'#{field_name}'"
    end

    def exports_to(field)
      value = field['ExportsTo']
      should_export = value.present? && !value&.match(/[!?]/)
      "exports_to: '#{value}'" if should_export
    end

    def invoice_total_value_field
      "total_value_field '#{miso_fields.invoice_total_value_field}'"
    end

    def order_total_value_field
      "total_value_field '#{miso_fields.order_total_value_field}'"
    end
  end
end
