module ActiveModel
  class Introspector
    class Field
      attr_reader :attr
      def initialize(attr, klass)
        @attr = attr
        @klass = klass
      end

      def validator_hash
        @validator_hash ||= @klass.validators_on(attr.name).each_with_object({}) do |validator, as_hash|
          validator_name = validator.class.to_s.underscore
                             .sub('active_model/validations/', '')
                             .sub('_validator', '').to_sym
          as_hash[validator_name] = validator.options.any? ? validator.options : true
        end
      end

      def exports_to
        @exports_to ||= @klass.export_mappings.key(attr.name)
      end

      def known?
        exports_to.present? && !additional?
      end

      def additional?
        exports_to.present? && exports_to =~ /^Additional[0-9]*$/
      end

      def strict_validators?
        validator_hash[:urn] ||
          validator_hash[:lot_in_agreement] ||
          validator_hash[:ingested_numericality] ||
          validator_hash[:ingested_date] ||
          validator_hash[:case_insensitive_inclusion] ||
          validator_hash[:dependent_field_inclusion]
      end

      def optional?
        validator_hash[:allow_nil] || (!strict_validators? && !validator_hash[:presence])
      end

      def inclusion_list_with_lookup_values?(value)
        value.is_a?(Array) && value.length > 0 && value != %w(Y N)
      end

      def type
        if validator_hash[:ingested_numericality] == true
          'Decimal'
        elsif validator_hash.dig(:ingested_numericality, :only_integer)
          'Integer'
        elsif validator_hash[:ingested_date]
          'Date'
        elsif validator_hash.dig(:case_insensitive_inclusion, :in) == %w[Y N]
          'YesNo'
        elsif inclusion_list_with_lookup_values?(validator_hash.dig(:case_insensitive_inclusion, :in))
          attr.name.tr(' ', '')
        else
          'String'
        end
      end

      def lhs
        if known?
          @klass.export_mappings.key(attr.name)
        elsif additional?
          "#{type} #{@klass.export_mappings.key(attr.name)}"
        else
          type
        end
      end

      def to_fdl
        "#{'optional ' if optional?}#{lhs} from '#{attr.name}'"
      end
    end
  end
end
