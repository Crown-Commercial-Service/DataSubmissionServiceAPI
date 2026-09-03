require 'rails_helper'

RSpec.describe '/v1' do
  let(:user) { FactoryBot.create(:user) }
  let(:headers) { { 'X-Auth-Id' => JWT.encode(user.auth_id, 'test') } }

  describe 'GET /v1/inactive_customers' do
    it 'returns 401 if authentication needed and not provided' do
      ClimateControl.modify API_PASSWORD: 'sdfhg' do
        get '/v1/inactive_customers', headers: headers
        expect(response.status).to eq(401)
      end
    end

    it 'returns 500 if X-Auth-Id header missing' do
      expect { get '/v1/inactive_customers' }.to raise_error(ActionController::BadRequest)
    end

    it 'returns ok if authentication needed and provided' do
      ClimateControl.modify API_PASSWORD: 'sdfhg' do
        get '/v1/inactive_customers', params: {}, headers: {
          HTTP_AUTHORIZATION: ActionController::HttpAuthentication::Basic.encode_credentials('dxw', 'sdfhg'),
          'X-Auth-Id' => JWT.encode(user.auth_id, 'test')
        }
        expect(response).to be_successful
      end
    end

    it 'returns a list of inactive customers' do
      inactive_customer1 = FactoryBot.create(:inactive_customer,
                                             inactive_urn: 123,
                                             inactive_customer_name: 'Customer One',
                                             replacement_urn: 456,
                                             replacement_customer_name: 'Replacement One',
                                             replacement_post_code: 'AB12 3CD')
      inactive_customer2 = FactoryBot.create(:inactive_customer,
                                             inactive_urn: 789,
                                             inactive_customer_name: 'Customer Two',
                                             replacement_urn: 101,
                                             replacement_customer_name: 'Replacement Two',
                                             replacement_post_code: 'EF45 6GH')

      get '/v1/inactive_customers', headers: headers

      expect(response).to be_successful

      expect(json['data'].map { |data| data['id'] }).to contain_exactly(inactive_customer1.id, inactive_customer2.id)

      json_inactive_customer = json['data'].find { |data| data['id'] == inactive_customer1.id }
      expect(json_inactive_customer).to have_attribute(:inactive_urn).with_value(inactive_customer1.inactive_urn)
      expect(json_inactive_customer).to have_attribute(:inactive_customer_name)
                                    .with_value(inactive_customer1.inactive_customer_name)
      expect(json_inactive_customer).to have_attribute(:replacement_urn)
                                    .with_value(inactive_customer1.replacement_urn)
      expect(json_inactive_customer).to have_attribute(:replacement_customer_name)
                                    .with_value(inactive_customer1.replacement_customer_name)
      expect(json_inactive_customer).to have_attribute(:replacement_post_code)
                                    .with_value(inactive_customer1.replacement_post_code)
    end

    it 'filters inactive customers by search query' do
      matching_customer = FactoryBot.create(
        :inactive_customer,
        inactive_urn: 123,
        inactive_customer_name: 'Ministry of Silly Walks'
      )
      FactoryBot.create(
        :inactive_customer,
        inactive_urn: 456,
        inactive_customer_name: 'Department of Serious Business'
      )

      get '/v1/inactive_customers', params: { filter: { search: 'Silly' } }, headers: headers

      expect(response).to be_successful

      expect(json['data'].map { |data| data['id'] }).to contain_exactly(matching_customer.id)
    end

    it 'returns pagination metadata in the response' do
      15.times do |i|
        FactoryBot.create(:inactive_customer,
                          inactive_urn: i,
                          inactive_customer_name: "Customer #{i}",
                          replacement_urn: i + 100,
                          replacement_customer_name: "Replacement #{i}",
                          replacement_post_code: "AB12 #{i}CD")
      end

      get '/v1/inactive_customers', params: { page: { page: 2 } }, headers: headers

      expect(response).to be_successful

      expect(json['meta']['pagination']['current_page']).to eq('2')
      expect(json['meta']['pagination']['per_page']).to eq(25)
      expect(json['meta']['pagination']['total_pages']).to eq(1)
      expect(json['meta']['pagination']['total']).to eq(15)
    end

    it 'returns the most recent inactive customers first' do
      inactive_customer1 = FactoryBot.create(:inactive_customer,
                                             inactive_urn: 123,
                                             inactive_customer_name: 'Customer One',
                                             replacement_urn: 456,
                                             replacement_customer_name: 'Replacement One',
                                             replacement_post_code: 'AB12 3CD',
                                             date_made_inactive: 2.days.ago)
      inactive_customer2 = FactoryBot.create(:inactive_customer,
                                             inactive_urn: 789,
                                             inactive_customer_name: 'Customer Two',
                                             replacement_urn: 101,
                                             replacement_customer_name: 'Replacement Two',
                                             replacement_post_code: 'EF45 6GH',
                                             date_made_inactive: 1.day.ago)

      get '/v1/inactive_customers', headers: headers

      expect(response).to be_successful

      expect(json['data'].map { |data| data['id'] }).to eq([inactive_customer2.id, inactive_customer1.id])
    end
  end
end
