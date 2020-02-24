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
          validator_hash[:numericality] ||
          validator_hash[:ingested_date]
      end

      def single_validator_allows_nil?
        validator_hash.length == 1 &&
          validator_hash.values.last.respond_to?(:[]) &&
          validator_hash.values.last[:allow_nil]
      end

      def optional?
        validator_hash[:allow_nil] ||
          (!strict_validators? && !validator_hash[:presence]) ||
          single_validator_allows_nil?
      end

      def inclusion_list_with_lookup_values?(value)
        value.is_a?(Array) && value.any? && value != %w[Y N]
      end

      # rubocop:disable Metrics/PerceivedComplexity
      # rubocop:disable Metrics/CyclomaticComplexity
      def type
        if validator_hash[:numericality] == true ||
           validator_hash[:numericality] == { allow_nil: true }
          'Decimal'
        elsif validator_hash.dig(:numericality, :only_integer)
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
      # rubocop:enable Metrics/PerceivedComplexity
      # rubocop:enable Metrics/CyclomaticComplexity

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
