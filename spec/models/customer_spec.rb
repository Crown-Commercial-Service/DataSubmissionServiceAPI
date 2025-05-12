require 'rails_helper'

RSpec.describe Customer do
  subject { FactoryBot.create(:customer) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:urn) }
  it { is_expected.to validate_presence_of(:sector) }

  it 'is associated with submission_entries via the URN' do
    customer = FactoryBot.create(:customer)
    submission_entry = FactoryBot.create(:submission_entry, customer_urn: customer.urn)

    expect(customer.submission_entries).to eq [submission_entry]
  end

  describe '.search' do
    let(:silly_walks_ministry) do
      FactoryBot.create(:customer, :central_government, name: 'Ministry of Silly Walks', urn: 12345678,
     postcode: 'AB1 2CD')
    end
    let(:outrageous_hats_ministry) do
      FactoryBot.create(:customer, :central_government, name: 'Ministry of Outrageous Hats', urn: 87654321,
     postcode: 'X1 2YZ')
    end
    let(:bobs_charity) do
      FactoryBot.create(:customer, :wider_public_sector, name: 'Bob’s Charity', urn: 12348765, postcode: 'CD1 2EF')
    end

    it 'returns customers with URNs matching the supplied search term' do
      expect(Customer.search('1234')).to match_array([silly_walks_ministry, bobs_charity])
      expect(Customer.search('098')).to match_array([])
    end

    it 'returns customers with names matching the supplied search term' do
      expect(Customer.search('Ministry')).to match_array([silly_walks_ministry, outrageous_hats_ministry])
      expect(Customer.search('Limited')).to match_array([])
    end

    it 'returns customers with postcodes matching the supplied search term' do
      expect(Customer.search('CD')).to match_array([silly_walks_ministry, bobs_charity])
      expect(Customer.search('X1')).to match_array([outrageous_hats_ministry])
      expect(Customer.search('FO0')).to match_array([])
    end

    it 'returns the scope for all customers if the query is blank' do
      expect(Customer.search(nil)).to eq Customer.all
      expect(Customer.search('')).to eq Customer.all
    end
  end
end
