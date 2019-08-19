require 'rails_helper'

RSpec.describe DependentFieldInclusionValidator do
  let(:entry_data_class) do
    Class.new(Framework::EntryData) do
      extend ActiveModel::Naming

      def self.name
        'Validator'
      end

      mapping = {
        'core'     => ['Corporate Finance'],
        'Non-core' => ['Equity Capital Markets'],
        'MIXTURE'  => ['Asset Finance']
      }

      field 'Service Type', :string
      field 'Primary Specialism', :string, dependent_field_inclusion: { parent: 'Service Type', in: mapping }
    end
  end

  let(:submission) { FactoryBot.create(:submission, framework: framework) }
  let(:framework)  { FactoryBot.create(:framework, short_name: 'RM3787') }
  let(:agreement)  { FactoryBot.create(:agreement, framework: framework, supplier: submission.supplier) }
  let(:entry)      { SubmissionEntry.new(submission: submission, data: data) }

  before { entry_data.validate }

  subject(:entry_data) { entry_data_class.new(entry) }

  context 'the dependent field corresponds to the parent field' do
    let(:data) { { 'Service Type' => 'Core', 'Primary Specialism' => 'Corporate Finance' } }

    it { is_expected.to be_valid }
  end

  context 'the dependent field corresponds to the parent field case-insensitively' do
    let(:data) { { 'Service Type' => 'Core', 'Primary Specialism' => 'CorPoRate FiNaNce' } }

    it { is_expected.to be_valid }
  end

  context 'the dependent field does not correspond to the parent field' do
    let(:data) { { 'Service Type' => 'Core', 'Primary Specialism' => 'Equity Capital Markets' } }

    it { is_expected.to_not be_valid }

    it 'has an error message' do
      expect(entry_data.errors['Primary Specialism'].first).to include(
        '"Equity Capital Markets" is not a valid Primary Specialism for the given Service Type of "Core".'
      )
    end
  end

  context 'the dependent field value is invalid' do
    let(:data) { { 'Service Type' => 'Core', 'Primary Specialism' => 'something else' } }

    it { is_expected.to_not be_valid }

    it 'has an error message' do
      expect(entry_data.errors['Primary Specialism'].first).to include(
        '"something else" is not a valid Primary Specialism for the given Service Type of "Core".'
      )
    end
  end

  context 'the dependent field value is missing' do
    let(:data) { { 'Service Type' => 'Core', 'Primary Specialism' => nil } }

    it { is_expected.to_not be_valid }
  end

  context 'the dependent field is missing' do
    let(:data) { { 'Service Type' => 'Core' } }

    it { is_expected.to_not be_valid }
  end

  context 'the parent field has a different casing' do
    let(:data) { { 'service type' => 'Core', 'Primary Specialism' => 'Equity Capital Markets' } }

    it { is_expected.to_not be_valid }
  end

  context 'the parent field has a value not present in our mapping' do
    let(:data) { { 'Service Type' => 'bogus', 'Primary Specialism' => 'Equity Capital Markets' } }

    it { is_expected.to_not be_valid }
  end

  context 'the parent field is missing entirely' do
    let(:data) { { 'Primary Specialism' => 'something else' } }

    it { is_expected.to_not be_valid }
  end
end
