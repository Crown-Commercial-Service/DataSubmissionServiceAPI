require_dependency 'framework'

class Framework
  module Definition
    class MissingError < StandardError; end

    class << self
      def [](framework_short_name)
        fdl_source = Framework.find_by(short_name: framework_short_name)&.definition_source

        raise Framework::Definition::MissingError, %(There is no framework definition for "#{framework_short_name}") \
          if fdl_source.blank?

        generator = Generator.new(fdl_source)
        generator.definition
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
          case entry_type.downcase
          when 'invoice' then self::Invoice
          when 'order' then self::Order
          when 'other' then self::Other
          else
            raise ArgumentError, "Unknown entry_type of #{entry_type}"
          end
        end

        def attributes_for_entry_type(entry_type)
          return [] unless constants.include?(entry_type.capitalize.to_sym)

          for_entry_type(entry_type).new(FakeAttributes.new).attributes.keys
        end

        class FakeAttributes
          def data
            {}
          end
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
