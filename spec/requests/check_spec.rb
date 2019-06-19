require 'rails_helper'

RSpec.describe '/check' do
  it 'returns status ok' do
    get '/check'

    expect(response).to be_successful
    expect(json['status']).to eq 'OK'
  end
end
