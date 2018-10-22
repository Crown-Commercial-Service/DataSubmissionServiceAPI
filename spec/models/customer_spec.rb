require 'rails_helper'

RSpec.describe Customer do
  subject { FactoryBot.create(:customer) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:urn) }
  it { is_expected.to validate_presence_of(:sector) }
  it { is_expected.to validate_uniqueness_of(:urn) }

  it 'is associated with submission_entries via the URN' do
    customer = FactoryBot.create(:customer)
    submission_entry = FactoryBot.create(:submission_entry, customer_urn: customer.urn)

    expect(customer.submission_entries).to eq [submission_entry]
  end
end
