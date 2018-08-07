require 'rails_helper'

RSpec.describe Supplier do
  it { is_expected.to have_many(:submissions) }
  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to have_many(:agreements) }
  it { is_expected.to have_many(:frameworks).through(:agreements) }
  it { is_expected.to have_many(:memberships) }

  it 'validates coda_reference begins with C0 and ends with 5 more digits' do
    valid_coda_references = %w[C012345 C002928 C099999]
    invalid_coda_references = %w[C012 D012345 C0AB123]

    valid_coda_references.each do |coda_reference|
      expect(FactoryBot.create(:supplier, coda_reference: coda_reference)).to be_valid
    end

    invalid_coda_references.each do |coda_reference|
      supplier = FactoryBot.build(:supplier, coda_reference: coda_reference)
      expect(supplier).not_to be_valid
      expect(supplier.errors[:coda_reference]).to be_present
    end
  end
end
