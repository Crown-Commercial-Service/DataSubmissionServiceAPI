require 'rails_helper'

RSpec.describe Framework do
  it { is_expected.to have_many(:lots) }
  it { is_expected.to have_many(:agreements) }
  it { is_expected.to have_many(:suppliers).through(:agreements) }
  it { is_expected.to have_many(:submissions) }

  describe 'validations' do
    subject { Framework.create(short_name: 'test') }
    it { is_expected.to validate_presence_of(:short_name) }
    it { is_expected.to validate_uniqueness_of(:short_name) }

    it 'validates coda_reference is a 7 digit number, beginning with 40' do
      valid_coda_references = %w[401234 400292 409999]
      invalid_coda_references = %w[4012 501234 40AB12]

      valid_coda_references.each do |coda_reference|
        expect(FactoryBot.create(:framework, coda_reference: coda_reference)).to be_valid
      end

      invalid_coda_references.each do |coda_reference|
        framework = FactoryBot.build(:framework, coda_reference: coda_reference)
        expect(framework).not_to be_valid
        expect(framework.errors[:coda_reference]).to be_present
      end
    end
  end
end
