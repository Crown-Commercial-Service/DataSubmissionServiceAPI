require 'rails_helper'

RSpec.describe CaseInsensitiveInclusionValidator do
  let(:entry_data_class) do
    Class.new(Framework::EntryData) do
      extend ActiveModel::Naming

      def self.name
        'Validator'
      end

      field 'Vat Included', :string, case_insensitive_inclusion: { in: %w[Y N] }
    end
  end

  it 'is valid when value is included in the list of valid values' do
    entry_data = entry_data_class.new(SubmissionEntry.new(data: { 'Vat Included' => 'Y' }))

    expect(entry_data).to be_valid
  end

  it 'is valid for values that differ in case from the list of valid values' do
    entry_data = entry_data_class.new(SubmissionEntry.new(data: { 'Vat Included' => 'n' }))

    expect(entry_data).to be_valid
  end

  it 'is invalid for values that are not in the list of valid values' do
    entry_data = entry_data_class.new(SubmissionEntry.new(data: { 'Vat Included' => 'x' }))

    expect(entry_data).not_to be_valid
  end

  it 'is valid for empty values' do
    entry_data = entry_data_class.new(SubmissionEntry.new(data: { 'Vat Included' => nil }))

    expect(entry_data).to be_valid
  end
end
