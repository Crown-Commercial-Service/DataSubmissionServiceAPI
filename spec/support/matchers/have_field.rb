##
# Matcher to allow the following forms:
#
# expect(an_entry_data_class).to have_field('My Field Name')
# expect(an_entry_data_class).to have_field('My Field Name').validated_by(:presence)
# expect(an_entry_data_class).to have_field('My Field Name').with_activemodel_type(:string)
# expect(an_entry_data_class).to have_field('My Field Name')
#   .validated_by(:presence, case_insensitive_inclusion: { in: %w[Y N]} )
# expect(an_entry_data_class).to have_field('My Field Name')
#   .validated_by(:presence)
#   .not_validated_by(:ingested_numericality)
RSpec::Matchers.define :have_field do |field_name|
  match do |actual_class|
    introspector = ActiveModel::Introspector.new(actual_class)

    field_exists = introspector.field_exists?(field_name)

    find_validator = ->(validator_arg) { introspector.validator_exists?(field_name, validator_arg) }
    mandatory_validators_present = (@validator_args || []).all?(&find_validator)
    unwanted_validators_absent   = (@not_validator_syms || []).none?(&find_validator)

    activemodel_type_valid =
      @expected_activemodel_type.nil? || introspector.type_of(field_name) == @expected_activemodel_type

    field_exists && mandatory_validators_present && unwanted_validators_absent && activemodel_type_valid
  end

  chain :validated_by do |*validator_args|
    @validator_args = validator_args
  end

  chain :not_validated_by do |*validator_syms|
    @not_validator_syms = validator_syms
  end

  chain :with_activemodel_type do |type|
    @expected_activemodel_type = type
  end
end
