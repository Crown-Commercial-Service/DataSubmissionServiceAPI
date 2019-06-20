require 'rails_helper'

RSpec.describe '/check' do
  it 'returns status ok' do
    ClimateControl.modify API_PASSWORD: 'sdfhg' do
      get '/check'
    end

    expect(response).to be_successful
    expect(json['status']).to eq 'OK'
  end
end
