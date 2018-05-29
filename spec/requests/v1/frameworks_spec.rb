require 'rails_helper'

RSpec.describe '/v1' do
  describe 'GET /frameworks' do
    it 'returns a list of frameworks' do
      FactoryBot.create(:framework, name: 'Cheese Board 8', short_name: 'cboard8')
      FactoryBot.create(:framework, name: 'Baked Goods Supply Services', short_name: 'RM0000')

      get '/v1/frameworks'

      expect(response).to be_successful
      expect(json['frameworks'].size).to eql 2

      expected = {
        frameworks: [
          { name: 'Cheese Board 8', short_name: 'cboard8' },
          { name: 'Baked Goods Supply Services', short_name: 'RM0000' }
        ]
      }

      expect(response.body).to include_json(expected)
    end
  end
end
