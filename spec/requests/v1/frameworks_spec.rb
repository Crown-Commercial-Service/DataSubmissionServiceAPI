require 'rails_helper'

RSpec.describe '/v1' do
  describe 'GET /frameworks' do
    it 'returns a list of frameworks' do
      FactoryBot.create(:framework, name: 'Cheese Board 8', short_name: 'cboard8')
      FactoryBot.create(:framework, name: 'Baked Goods Supply Services', short_name: 'RM0000')

      get '/v1/frameworks'

      expect(response).to be_successful

      expect(json['data'][0]).to have_attribute(:name).with_value('Cheese Board 8')
      expect(json['data'][0]).to have_attribute(:short_name).with_value('cboard8')

      expect(json['data'][1]).to have_attribute(:name).with_value('Baked Goods Supply Services')
      expect(json['data'][1]).to have_attribute(:short_name).with_value('RM0000')
    end
  end

  describe 'GET /frameworks/:id' do
    it 'returns the requested framework' do
      framework = FactoryBot.create(:framework, name: 'Cheese Board 8', short_name: 'cboard8')

      get "/v1/frameworks/#{framework.id}"

      expect(response).to be_successful

      expect(json['data']).to have_attribute(:name).with_value('Cheese Board 8')
      expect(json['data']).to have_attribute(:short_name).with_value('cboard8')
    end
  end
end
