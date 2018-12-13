require 'rails_helper'

RSpec.describe LotInAgreementValidator do
  let(:entry_data_class) do
    Class.new(Framework::EntryData) do
      extend ActiveModel::Naming

      def self.name
        'Validator'
      end

      field 'Lot Number', :string, lot_in_agreement: true
    end
  end

  let(:supplier) { submission.supplier }
  let(:framework) { FactoryBot.create(:framework, lot_count: 2, short_name: 'RM3767') }
  let(:submission) { FactoryBot.create(:submission, framework: framework) }
  let(:agreement) { FactoryBot.create(:agreement, framework: framework, supplier: supplier) }
  let(:agreement_lot) { framework.lots.first }
  let!(:agreement_framework_lot) do
    FactoryBot.create(:agreement_framework_lot, agreement: agreement, framework_lot: agreement_lot)
  end

  it 'is valid for lot numbers in the supplier agreement' do
    entry = SubmissionEntry.new(submission: submission, data: { 'Lot Number' => agreement_lot.number })
    entry_data = entry_data_class.new(entry)

    expect(entry_data).to be_valid
  end

  it 'is invalid for lot numbers that are part of the framework but not in the supplier agreement' do
    entry = SubmissionEntry.new(submission: submission, data: { 'Lot Number' => framework.lots.last })
    entry_data = entry_data_class.new(entry)

    expect(entry_data).not_to be_valid
    expect(entry_data.errors['Lot Number']).to eq(['is not included in the supplier framework agreement'])
  end

  it 'is invalid for lot numbers not in the framework' do
    entry = SubmissionEntry.new(submission: submission, data: { 'Lot Number' => 'XXX' })
    entry_data = entry_data_class.new(entry)

    expect(entry_data).not_to be_valid
    expect(entry_data.errors['Lot Number']).to eq(['is not included in the supplier framework agreement'])
  end
end
