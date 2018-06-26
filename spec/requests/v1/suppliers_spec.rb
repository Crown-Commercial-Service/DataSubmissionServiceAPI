require 'rails_helper'

RSpec.describe '/v1' do
  describe 'GET /suppliers' do
    it 'returns a list of suppliers' do
      FactoryBot.create(:supplier, name: 'A1 Cakes Ltd')
      FactoryBot.create(:supplier, name: 'Bakery Plus')

      get '/v1/suppliers'

      expect(response).to be_successful

      expect(json['data'][0]).to have_attribute(:name).with_value('A1 Cakes Ltd')
      expect(json['data'][1]).to have_attribute(:name).with_value('Bakery Plus')
    end
  end
end
