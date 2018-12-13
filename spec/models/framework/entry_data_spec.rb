require 'rails_helper'

RSpec.describe Framework::EntryData do
  let(:entry_data_class) do
    Class.new(Framework::EntryData) do
      field 'Test Field', :string
    end
  end

  describe '.new' do
    it 'sets attributes from the entry’s data' do
      submission_entry = SubmissionEntry.new(data: { 'Test Field' => 'test' })
      entry_data = entry_data_class.new(submission_entry)
      expect(entry_data.attributes).to include('Test Field' => 'test')
    end

    it 'ignores parameters that do not exist in the entry data definition' do
      submission_entry = SubmissionEntry.new(
        data: {
          'Test Field' => 'test',
          'Missing from Sheet' => true
        }
      )
      entry_data = entry_data_class.new(submission_entry)

      expect(entry_data.attributes).not_to include('Missing from Sheet')
    end
  end

  describe '#valid_lot_numbers' do
    let(:agreement) { FactoryBot.create(:agreement, framework: framework) }
    let(:framework) { FactoryBot.create(:framework, lot_count: 2) }
    let(:submission) { FactoryBot.create(:submission, framework: framework, supplier: agreement.supplier) }
    let(:submission_entry) { FactoryBot.create(:submission_entry, submission: submission) }
    let(:entry_data) { entry_data_class.new(submission_entry) }

    it 'returns the lot numbers the supplier’s agreement is valid against' do
      expect(entry_data.valid_lot_numbers).to eq []

      agreement.agreement_framework_lots.create!(framework_lot: framework.lots.first)
      expect(entry_data.valid_lot_numbers).to eq [framework.lots.first.number]
    end
  end
end
