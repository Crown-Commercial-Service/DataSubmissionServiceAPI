require 'rails_helper'

RSpec.describe '/v1' do
  describe 'POST /customer_effort_scores' do
    let(:user) { FactoryBot.create(:user) }

    context 'the user rates the experience as very easy' do
      let(:params) do
        {
          data: {
            type: 'customer_effort_scores',
            attributes: {
              rating: 'Very easy',
            comments: 'Never been happier',
            user_id: user.id
            }
          }
        }
      end

      it 'saves customer feedback' do
        post '/v1/customer_effort_scores', params: params.to_json,
          headers: json_headers.merge('X-Auth-Id' => user.auth_id)

        expect(response).to have_http_status(204)

        score = CustomerEffortScore.first

        expect(score.rating).to eq(5)
        expect(score.comments).to eq('Never been happier')
        expect(score.user_id).to eq(user.id)
      end
    end

    context 'the user rates the experience as easy' do
      let(:params) do
        {
          data: {
            type: 'customer_effort_scores',
            attributes: {
              rating: 'Easy',
            comments: '',
            user_id: user.id
            }
          }
        }
      end
      
      it 'saves customer feedback' do
        post '/v1/customer_effort_scores', params: params.to_json,
          headers: json_headers.merge('X-Auth-Id' => user.auth_id)

        expect(response).to have_http_status(204)

        score = CustomerEffortScore.first

        expect(score.rating).to eq(4)
      end
    end

    context 'the user rates the experience as Neither easy or difficult' do
      let(:params) do
        {
          data: {
            type: 'customer_effort_scores',
            attributes: {
              rating: 'Neither easy or difficult',
            comments: '',
            user_id: user.id
            }
          }
        }
      end
      
      it 'saves customer feedback' do
        post '/v1/customer_effort_scores', params: params.to_json,
          headers: json_headers.merge('X-Auth-Id' => user.auth_id)

        expect(response).to have_http_status(204)

        score = CustomerEffortScore.first

        expect(score.rating).to eq(3)
      end
    end

    context 'the user rates the experience as difficult' do
      let(:params) do
        {
          data: {
            type: 'customer_effort_scores',
            attributes: {
              rating: 'Difficult',
            comments: '',
            user_id: user.id
            }
          }
        }
      end
      
      it 'saves customer feedback' do
        post '/v1/customer_effort_scores', params: params.to_json,
          headers: json_headers.merge('X-Auth-Id' => user.auth_id)

        expect(response).to have_http_status(204)

        score = CustomerEffortScore.first

        expect(score.rating).to eq(2)
      end
    end

    context 'the user rates the experience as very difficult' do
      let(:params) do
        {
          data: {
            type: 'customer_effort_scores',
            attributes: {
              rating: 'Very difficult',
            comments: '',
            user_id: user.id
            }
          }
        }
      end
      
      it 'saves customer feedback' do
        post '/v1/customer_effort_scores', params: params.to_json,
          headers: json_headers.merge('X-Auth-Id' => user.auth_id)

        expect(response).to have_http_status(204)

        score = CustomerEffortScore.first

        expect(score.rating).to eq(1)
      end
    end

    context 'the user does not select a rating' do
      let(:params) do
        {
          data: {
            type: 'customer_effort_scores',
            attributes: {
              rating: nil,
            comments: '',
            user_id: user.id
            }
          }
        }
      end
      
      it 'responds with an error status' do
        post '/v1/customer_effort_scores', params: params.to_json,
          headers: json_headers.merge('X-Auth-Id' => user.auth_id)

        expect(response).to have_http_status(400)

        expect(response).to_not be_successful
      end
    end
  end
end
