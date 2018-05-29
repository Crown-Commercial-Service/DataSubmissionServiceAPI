require 'rails_helper'

RSpec.describe '/v1' do
  describe 'GET /suppliers' do
    it 'returns a list of suppliers' do
      FactoryBot.create(:supplier, name: 'A1 Cakes Ltd')
      FactoryBot.create(:supplier, name: 'Bakery Plus')

      get '/v1/suppliers'

      expect(response).to be_successful

      expected = {
        suppliers: [
          { name: 'A1 Cakes Ltd' },
          { name: 'Bakery Plus' }
        ]
      }

      expect(response.body).to include_json(expected)
    end
  end
end
