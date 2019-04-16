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

  describe '.new_from_fdl' do
    subject(:framework) { Framework.new_from_fdl(definition_source) }

    before { framework.validate }

    context 'with some valid FDL' do
      let(:definition_source) do
        <<~FDL
          Framework RM999 {
            Name 'Parsed correctly'
            ManagementCharge 0.5% of 'Supplier Price'
             InvoiceFields {
              InvoiceValue from 'Supplier Price'
            }
          }
        FDL
      end

      it { is_expected.to be_valid }
      it { is_expected.not_to be_persisted }
      it 'has a name' do
        expect(framework.name).to eql('Parsed correctly')
      end
    end

    context 'with some invalid FDL' do
      let(:definition_source) do
        <<~FDL
          Framework RM999 {
            xName 'Parsed incorrectly'
            ManagementCharge 0.5% of 'Supplier Price'
             InvoiceFields {
              InvoiceValue from 'Supplier Price'
            }
          }
        FDL
      end

      it { is_expected.not_to be_valid }
      it { is_expected.not_to be_persisted }
      it 'has the parse error as an error on definition_source' do
        expect(framework.errors[:definition_source].first).to match('Failed to match sequence')
      end
    end
  end

  describe '#update_from_fdl' do
    let!(:existing_framework) { create :framework, short_name: 'RM999', name: 'To be updated' }

    subject! { existing_framework.update_from_fdl(definition_source) }

    context 'with some valid FDL' do
      let(:definition_source) do
        <<~FDL
          Framework RM999 {
            Name 'Changed successfully'
            ManagementCharge 0.5% of 'Supplier Price'
             InvoiceFields {
              InvoiceValue from 'Supplier Price'
            }
          }
        FDL
      end

      it { is_expected.to be true }

      it 'has updated its name' do
        expect(existing_framework.reload.name).to eql('Changed successfully')
      end
    end

    context 'with some invalid FDL' do
      let(:definition_source) do
        <<~FDL
          Framework RM999 {
            xName 'Parsed incorrectly'
            ManagementCharge 0.5% of 'Supplier Price'
             InvoiceFields {
              InvoiceValue from 'Supplier Price'
            }
          }
        FDL
      end

      it { is_expected.to be false }

      it 'has the error' do
        expect(existing_framework.errors[:definition_source].first).to match('Failed to match sequence')
      end
    end
  end
end
