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
      expect(data.first).to have_attributes(:short_name, :name)
    end
  end

  describe 'GET /v1/frameworks/:framework_id?include_file=true' do
    it 'returns the details of a given framework, with file_key' do
      framework = FactoryBot.create(:framework, :with_attachment, name: 'G-Cloud 42', short_name: 'RM1234')

      get "/v1/frameworks/#{framework.id}?include_file=true"

      expect(response).to be_successful

      expect(json['data']).to have_id(framework.id)

      expect(json['data']).to have_attributes(:name, :short_name, :file_name)

      expect(json['data'])
        .to have_attribute(:file_key)
        .with_value(framework.file_key)
    end
  end
end
