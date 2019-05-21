require 'rails_helper'

RSpec.describe '/v1' do
  let!(:urn_list) do
    create(:urn_list, aasm_state: :processed)
  end

  describe 'GET /v1/urn_lists' do
    subject(:data) { json['data'] }

    it 'returns the latest processed URN list, without authentication' do
      create(:urn_list, aasm_state: :failed, created_at: 1.hour.from_now)
      create(:urn_list, aasm_state: :pending)

      get '/v1/urn_lists'

      expect(response).to be_successful

      expect(data).to have_id(urn_list.id)
      expect(data).to have_attributes(:filename, :file_key, :byte_size)
    end
  end
end
