require 'rails_helper'

RSpec.describe UrnList do
  describe '#file_name' do
    it 'returns the filename of the attachment' do
      submission_file = FactoryBot.create(:urn_list)

      expect(submission_file.file_name).to eq 'customers_test.xlsx'
    end

    it 'returns nil if no file attachment exists' do
      expect(UrnList.new.file_name).to be_nil
    end
  end

  describe '#file_key' do
    it 'returns the filename of the attachment' do
      submission_file = FactoryBot.create(:urn_list)

      expect(submission_file.file_key).to be_present
    end

    it 'returns nil if no file attachment exists' do
      expect(UrnList.new.file_key).to be_nil
    end
  end
end
