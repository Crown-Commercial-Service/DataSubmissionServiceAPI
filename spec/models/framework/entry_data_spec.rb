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
end
