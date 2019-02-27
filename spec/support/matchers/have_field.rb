##
# Matcher to allow the following forms:
#
# expect(an_entry_data_class).to have_field('My Field Name')
# expect(an_entry_data_class).to have_field('My Field Name').validated_by(:presence)
# expect(an_entry_data_class).to have_field('My Field Name')
#   .validated_by(:presence, case_insensitive_inclusion: { in: %w[Y N]} )
# expect(an_entry_data_class).to have_field('My Field Name')
#   .validated_by(:presence)
#   .not_validated_by(:ingested_numericality)
RSpec::Matchers.define :have_field do |field_name|
  match do |actual_class|
    find_proc = lambda do |validator_arg|
      also_match_opts = {}

      key = if validator_arg.is_a?(Symbol)
              "#{validator_arg.to_s.camelize}Validator"
            elsif validator_arg.is_a?(Hash)
              also_match_opts = validator_arg[validator_arg.keys.first]
              "#{validator_arg.keys.first.to_s.camelize}Validator"
            end

      begin
        validator_class = key.constantize
      rescue NameError
        # Look in both root namespace and ActiveModel::Validations namespace and
        # give up when we've tried the latter
        if key.match?(/^ActiveModel/)
          raise ArgumentError, "Not a validator: '#{key.sub('ActiveModel::Validations::', '')}'"
        end

        key = "ActiveModel::Validations::#{key}"
        retry
      end

      actual_class.validators_on(field_name).find do |validator|
        validator_exists = validator.class == validator_class && validator.attributes == [field_name]
        if also_match_opts.any?
          validator_exists && validator.options == also_match_opts
        else
          validator_exists
        end
      end
    end

    empty_entry = Struct.new(:data).new(data: {})
    instance_of_actual_klass = actual_class.new(empty_entry)

    field_exists = instance_of_actual_klass.attributes.key?(field_name)

    mandatory_validators_present = (@validator_args || []).all?(&find_proc)
    unwanted_validators_absent   = (@not_validator_syms || []).none?(&find_proc)

    field_exists && mandatory_validators_present && unwanted_validators_absent
  end

  chain :validated_by do |*validator_args|
    @validator_args = validator_args
  end

  chain :not_validated_by do |*validator_syms|
    @not_validator_syms = validator_syms
  end
end
