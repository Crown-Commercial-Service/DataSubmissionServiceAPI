require 'rails_helper'

RSpec.describe UrnValidator do
  let(:entry_data_class) do
    Class.new(Framework::EntryData) do
      extend ActiveModel::Naming

      def self.name
        'Validator'
      end

      field 'Customer URN', :string, urn: true
    end
  end

  subject(:entry_data) do
    entry_data_class.new(SubmissionEntry.new(data: { 'Customer URN' => urn }))
  end

  before do
    create(:customer, urn: 12345678, deleted: deleted)
  end

  let(:deleted) { false }

  context 'URN exists' do
    let(:urn) { '12345678' }

    it { is_expected.to be_valid }
  end

  context 'URN is missing' do
    let(:urn) { '88888888' }

    it { is_expected.not_to be_valid }
  end

  context 'URN is soft-deleted' do
    let(:urn) { '12345678' }
    let(:deleted) { true }

    it { is_expected.not_to be_valid }
  end

  context 'with a value that Ruby would incorrectly coerce with to_i to 12345678' do
    let(:urn) { '12345678 Hey Duggee' }

    it { is_expected.not_to be_valid }
  end
end
