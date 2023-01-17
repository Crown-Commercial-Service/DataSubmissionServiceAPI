require 'rails_helper'

RSpec.describe '/v1' do
  let(:user) { FactoryBot.create(:user) }

  let(:supplier) do
    supplier = FactoryBot.create(:supplier)
    Membership.create(supplier: supplier, user: user)
    supplier
  end

  describe 'GET /v1/agreements' do
    it 'returns 401 if authentication needed and not provided' do
      ClimateControl.modify API_PASSWORD: 'sdfhg' do
        get '/v1/agreements', headers: { 'X-Auth-Id' => user.auth_id }
        expect(response.status).to eq(401)
      end
    end

    it 'returns 500 if X-Auth-Id header missing' do
      expect { get '/v1/agreements' }.to raise_error(ActionController::BadRequest)
    end

    it 'returns ok if authentication needed and provided' do
      ClimateControl.modify API_PASSWORD: 'sdfhg' do
        get '/v1/agreements', params: {}, headers: {
          HTTP_AUTHORIZATION: ActionController::HttpAuthentication::Basic.encode_credentials('dxw', 'sdfhg'),
          'X-Auth-Id' => user.auth_id
        }
        expect(response).to be_successful
      end
    end

    it 'returns a list of agreements' do
      framework1 = FactoryBot.create(:framework, name: 'Framework 123')
      framework2 = FactoryBot.create(:framework, name: 'Framework xyz')
      agreement1 = FactoryBot.create(:agreement, active: true, framework: framework1, supplier: supplier)
      agreement2 = FactoryBot.create(:agreement, active: false, framework: framework2, supplier: supplier)

      get '/v1/agreements', headers: { 'X-Auth-Id' => user.auth_id }

      expect(response).to be_successful

      expect(json['data'].map { |data| data['id'] }).to contain_exactly(agreement1.id, agreement2.id)

      json_agreement1 = json['data'].find { |data| data['id'] == agreement1.id }
      expect(json_agreement1).to have_attribute(:active).with_value(true)
      expect(json_agreement1).to have_attribute(:relevant_lots)

      json_agreement2 = json['data'].find { |data| data['id'] == agreement2.id }
      expect(json_agreement2).to have_attribute(:active).with_value(false)
    end

    it 'does not include agreements that do not belong to suppliers linked to the current user' do
      framework1 = FactoryBot.create(:framework, name: 'Framework 123')
      framework2 = FactoryBot.create(:framework, name: 'Framework xyz')
      FactoryBot.create(:agreement, active: true, framework: framework1, supplier: supplier)
      FactoryBot.create(:agreement, active: false, framework: framework2)

      get '/v1/agreements', headers: { 'X-Auth-Id' => user.auth_id }

      expect(response).to be_successful

      expect(json['data'].size).to eql 1
      expect(json['data'][0]).to have_attribute(:framework_id).with_value(framework1.id)
    end

    it 'can include framework and supplier' do
      framework = FactoryBot.create(:framework, name: 'Framework 123')
      agreement = FactoryBot.create(:agreement, active: true, framework: framework, supplier: supplier)

      get '/v1/agreements?include=framework,supplier', headers: { 'X-Auth-Id' => user.auth_id }

      expect(response).to be_successful
      expect(json['data'][0]).to have_id(agreement.id)
      expect(json['data'][0])
        .to have_relationship(:framework)
        .with_data({ 'type' => 'frameworks', 'id' => framework.id })
      expect(json['data'][0])
        .to have_relationship(:supplier)
        .with_data({ 'type' => 'suppliers', 'id' => supplier.id })
    end
  end
end
