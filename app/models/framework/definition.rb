require 'framework'

class Framework
  module Definition
    class MissingError < StandardError; end

    class << self
      def cache
        @cache ||=
          Hash.new do |hash, framework_short_name|
            hash[framework_short_name] = Framework::Definition::Language[framework_short_name]
          rescue ArgumentError
            raise Framework::Definition::MissingError, %(There is no framework definition for "#{framework_short_name}")
          end
      end

      def [](framework_short_name)
        sanitized_framework_short_name = framework_short_name.tr('/.', '_')
        cache[sanitized_framework_short_name]
      end

      # remove when the fdl_generator is removed
      def from_ruby(framework_short_name)
        sanitized_framework_short_name = framework_short_name.tr('/.', '_')
        "Framework::Definition::#{sanitized_framework_short_name}".constantize
      rescue NameError
        raise Framework::Definition::MissingError, %(There is no framework definition for "#{framework_short_name}")
      end
    end

    ##
    # Base class for a framework definition with metadata methods
    class Base
      include Framework::ManagementChargeCalculator

      class << self
        ##
        # E.g. "Rail Legal Services"
        def framework_name(framework_name = nil)
          @framework_name ||= framework_name
        end

        ##
        # E.g. "RM3786"
        def framework_short_name(framework_short_name = nil)
          @framework_short_name ||= framework_short_name
        end

        def management_charge(calculator = nil)
          @management_charge ||= calculator
        end

        def lots(lots = nil)
          @lots ||= lots
        end

        def calculate_management_charge(entry)
          management_charge.calculate_for(entry)
        end

        def for_entry_type(entry_type)
          entry_type == 'invoice' ? self::Invoice : self::Order
        end
      end
    end

    # Require all the framework definitions up-front
    Dir['app/models/framework/definition/*.rb'].each do |definition|
      # `Dir` needs an app-relative path argument, but `require` needs one relative to
      # the $LOAD_PATH. Remove app/models/ to e.g. only `require 'framework/definition/RM1234'`
      relative_definition = Pathname(definition).sub('app/models/', '').sub_ext('').to_s
      require relative_definition
    end
  end
end
