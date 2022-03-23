require 'rails_helper'

RSpec.describe '/v1' do
  before do
    create(:framework, published: true)
    create(:framework, published: true)
    create(:framework, published: false)
  end

  describe 'GET /v1/frameworks' do
    subject(:data) { json['data'] }

    it 'returns a list of all published frameworks without authentication' do
      get '/v1/frameworks'

      expect(response).to be_successful
      expect(data.size).to eq(2)
      #expect(data.first).to have_attributes(:short_name)
      expect(data.first).to have_attributes(:name)
    end
  end
end
