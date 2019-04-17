require 'rails_helper'

RSpec.describe '/v1' do
  before do
    create(:framework)
    create(:framework)
  end

  describe 'GET /v1/frameworks' do
    subject(:data) { json['data'] }

    it 'returns a list of all the frameworks without authentication' do
      get '/v1/frameworks'

      expect(response).to be_successful
      expect(data.size).to eq(2)
      expect(data.first).to have_attributes(:short_name, :name)
    end
  end
end
