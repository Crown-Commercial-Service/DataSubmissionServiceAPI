require 'rails_helper'

RSpec.describe '/v1' do
  describe 'POST /customer_effort_scores' do
    let(:user) { FactoryBot.create(:user) }

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
end
