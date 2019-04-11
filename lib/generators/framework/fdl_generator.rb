require 'framework' # failure to require this here will result in autoload problems
require 'active_model/introspector'
require 'active_model/introspector/lookups'

class Framework
  ##
  # Create a Framework::Definition derivative given a
  # framework_short_name. See USAGE
  class FdlGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('templates', __dir__)

    def create_framework_fdl_file
      template(
        'framework_definition.fdl.erb',
        "app/models/framework/definition/#{sanitised_framework_short_name}.fdl"
      )
    end

    private

    def sanitised_framework_short_name
      name.tr('/.', '_')
    end

    def framework_short_name
      name
    end

    def ruby_definition
      @ruby_definition ||= Framework::Definition.from_ruby(sanitised_framework_short_name)
    end

    def management_charge
      ruby_definition.management_charge
    end

    def framework_name
      ruby_definition.framework_name
    end

    def invoice_introspector
      @invoice_introspector ||= ActiveModel::Introspector.new(ruby_definition::Invoice)
    end

    def contract_introspector
      @contract_introspector ||= ActiveModel::Introspector.new(ruby_definition::Order)
    end

    def invoice_fields
      ruby_definition.const_defined?(:Invoice) ? invoice_introspector.fields : []
    end

    def contract_fields
      ruby_definition.const_defined?(:Order) ? contract_introspector.fields : []
    end

    def lookups
      ActiveModel::Introspector::Lookups.new(ruby_definition)
    end
  end
end
