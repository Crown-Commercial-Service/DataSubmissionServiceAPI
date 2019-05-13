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

  describe '#load_lots!' do
    subject!(:framework) { create(:framework, definition_source: definition_source) }
    context 'with an FDL with lots' do
      let(:definition_source) do
        <<~FDL
          Framework RM999 {
            Name 'Changed successfully'
            ManagementCharge 0.5% of 'Supplier Price'
             InvoiceFields {
              InvoiceValue from 'Supplier Price'
            }
            Lots {
              '1' -> 'Lot 1'
              '2' -> 'Second Lot'
            }
          }
        FDL
      end

      it 'loads the lots into the database' do
        expect { subject.load_lots! }.to change { subject.lots.count }.by(2)
        expect(subject.lots.find_by(number: '1', description: 'Lot 1')).to be_a(FrameworkLot)
      end

      context 'when framework already has a lot with agreements with the same number' do
        let!(:framework_lot) { create(:framework_lot, framework: framework, number: '2', description: 'Lot 2') }
        let!(:agreement_framework_lot) { create(:agreement_framework_lot, framework_lot: framework_lot) }

        it 'updates the description of the lot' do
          expect { subject.load_lots! }.to change { subject.lots.count }.by(1)
          expect(subject.lots.find_by(number: '2', description: 'Second Lot')).to be_a(FrameworkLot)
        end
      end

      context 'when framework already has a lot with a number not in the FDL' do
        let!(:framework_lot) { create(:framework_lot, framework: framework, number: '3') }

        context 'that has no agreements against it' do
          it 'deletes that lot from the database' do
            expect { subject.load_lots! }.to change { subject.lots.count }.by(1)
            expect(subject.lots.find_by(number: '1', description: 'Lot 1')).to be_a(FrameworkLot)
            expect(subject.lots.find_by(number: '3')).to eq(nil)
          end
        end

        context 'that has agreements against it' do
          let!(:agreement_framework_lot) { create(:agreement_framework_lot, framework_lot: framework_lot) }

          it 'raises an error' do
            expect { subject.load_lots! }.to raise_error(ActiveRecord::InvalidForeignKey)
          end
        end
      end
    end

    context 'with an FDL without lots' do
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

      it 'does nothing' do
        expect { subject.load_lots! }.to_not change { subject.lots.count }
      end

      context 'when framework already has a lot' do
        let!(:framework_lot) { create(:framework_lot, framework: framework, number: '3') }

        context 'that has no agreements against it' do
          it 'deletes that lot from the database' do
            expect { subject.load_lots! }.to change { subject.lots.count }.by(-1)
            expect(subject.lots.find_by(number: '3')).to eq(nil)
          end
        end

        context 'that has agreements against it' do
          let!(:agreement_framework_lot) { create(:agreement_framework_lot, framework_lot: framework_lot) }

          it 'raises an error' do
            expect { subject.load_lots! }.to raise_error(ActiveRecord::InvalidForeignKey)
          end
        end
      end
    end
  end
end
