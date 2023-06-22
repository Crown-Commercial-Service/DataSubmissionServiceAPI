require 'active_model/introspector/field'

module ActiveModel
  ##
  # Helps to introspect an ActiveModel class with attributes and validators.
  #
  # e.g. +introspector = Introspector.new(klass)+
  #      +introspector.validator_exists?(:case_insensitive_inclusion, in: %w[Y N])+
  class Introspector
    attr_reader :klass
    def initialize(klass)
      @klass = klass
    end

    def attributes
      @attributes ||= instance.instance_variable_get(:@attributes)
    end

    def fields
      attributes.keys.map { |k| Field.new(attributes[k], klass) }
    end

    def field_exists?(field)
      instance.attributes.key?(field)
    end

    # rubocop:disable Metrics/AbcSize
    def validator_exists?(field, validator_arg)
      also_match_opts = {}

      key = case validator_arg
            when Symbol
              "#{validator_arg.to_s.camelize}Validator"
            when Hash
              also_match_opts = validator_arg[validator_arg.keys.first]
              "#{validator_arg.keys.first.to_s.camelize}Validator"
            else
              raise ArgumentError, 'validator_arg takes Symbol or Hash only'
            end

      validator_class = lookup_validator_class(key)

      klass.validators_on(field).find do |validator|
        validator_exists = validator.class == validator_class && validator.attributes == [field]
        if also_match_opts.any?
          validator_exists && validator.options == also_match_opts
        else
          validator_exists
        end
      end
    end
    # rubocop:enable Metrics/AbcSize

    def validator_summary(field)
      validators_found = klass.validators_on(field).map do |validator|
        validator_name = validator.class.to_s.underscore
                                  .sub('active_model/validations/', '')
                                  .sub('_validator', '')

        "\t#{validator_name}: #{validator.options.any? ? validator.options : true}"
      end.join("\n")

      "Validators found:\n#{validators_found}"
    end

    ##
    # An ActiveModel symbol type, e.g. +:string+
    def type_of(field)
      attributes[field].type.type
    end

    def instance
      @instance ||= klass.new(empty_entry)
    end

    private

    ##
    # Translate a given symbol like :presence or :ingested_date
    # to its actual validator class.
    #
    # Look in root namespace and ActiveModel::Validations namespace and
    # give up when we've tried the latter
    def lookup_validator_class(key)
      key = Kernel.const_defined?(key) ? key : "ActiveModel::Validations::#{key}"
      key.constantize
    end

    def empty_entry
      @empty_entry ||= Struct.new(:data).new({data: {}})
    end
  end
end
