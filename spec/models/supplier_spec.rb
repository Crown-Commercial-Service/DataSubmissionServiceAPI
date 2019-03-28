require 'rails_helper'

RSpec.describe Supplier do
  it { is_expected.to have_many(:submissions) }
  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to have_many(:agreements) }
  it { is_expected.to have_many(:frameworks).through(:agreements) }
  it { is_expected.to have_many(:memberships) }

  it 'validates coda_reference begins with C0 and ends with 4-5 more digits' do
    valid_coda_references = %w[C012345 C002928 C099999 C07232]
    invalid_coda_references = %w[C012 D012345 C0AB123]

    valid_coda_references.each do |coda_reference|
      expect(FactoryBot.build(:supplier, coda_reference: coda_reference)).to be_valid
    end

    invalid_coda_references.each do |coda_reference|
      supplier = FactoryBot.build(:supplier, coda_reference: coda_reference)
      expect(supplier).not_to be_valid
      expect(supplier.errors[:coda_reference]).to be_present
    end
  end

  describe '.search' do
    let!(:east_wind) { FactoryBot.create(:supplier, name: 'East Wind') }
    let!(:ecm) { FactoryBot.create(:supplier, name: 'ECM') }
    let!(:impulse) { FactoryBot.create(:supplier, name: 'Impulse') }
    let!(:strata_east) { FactoryBot.create(:supplier, name: 'Strata East') }

    it 'returns suppliers with names matching the query' do
      expect(Supplier.search('east')).to match_array([east_wind, strata_east])
      expect(Supplier.search('strata')).to match_array([strata_east])
      expect(Supplier.search('bob')).to be_empty
    end

    it 'returns the scope for all suppliers if the query is blank' do
      expect(Supplier.search(nil)).to eq Supplier.all
    end
  end

  describe '#agreement_for_framework' do
    let(:supplier) { FactoryBot.create(:supplier) }
    let(:framework) { FactoryBot.create(:framework) }

    it 'returns the agreement a supplier has for a given framework' do
      agreement = FactoryBot.create(:agreement, supplier: supplier, framework: framework)

      expect(supplier.agreement_for_framework(framework)).to eq agreement
    end

    it 'it raises an error if the supplier does not have an agreement on the framework' do
      expect { supplier.agreement_for_framework(framework) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
