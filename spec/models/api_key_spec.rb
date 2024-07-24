require 'rails_helper'

RSpec.describe ApiKey do
  it 'verifies that the key is generated' do
    expect(ApiKey.count).to eq 0
    FactoryBot.create(:api_key)
    expect(ApiKey.count).to eq 1
    expect(ApiKey.first.key).not_to be_empty
  end
end
