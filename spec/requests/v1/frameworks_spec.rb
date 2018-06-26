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

      expected = {
        name: 'Cheese Board 8',
        short_name: 'cboard8'
      }

      expect(response.body).to include_json(expected)
    end

    it 'includes the list of lots on that framework' do
      framework = FactoryBot.create(:framework, name: 'Cheese Board 8', short_name: 'cboard8')

      FactoryBot.create(:framework_lot, number: '1a', framework: framework)
      FactoryBot.create(:framework_lot, number: '1b', framework: framework)

      get "/v1/frameworks/#{framework.id}"

      expect(response).to be_successful

      expected = {
        name: 'Cheese Board 8',
        short_name: 'cboard8',
        lots: [
          { number: '1a' },
          { number: '1b' }
        ]
      }

      expect(response.body).to include_json(expected)
    end
  end
end
