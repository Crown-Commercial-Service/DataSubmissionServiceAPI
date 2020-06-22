require 'rails_helper'

RSpec.describe Onboard::FrameworkSuppliers::Row do
  describe '#onboard!' do
    let!(:framework) { FactoryBot.create(:framework) }
    let(:framework_short_name) { framework.short_name }
    let!(:lot_1) { framework.lots.create!(number: '1') }
    let(:lot_number) { lot_1.number }
    let(:supplier_name) { 'Big Dog Limited' }
    let(:salesforce_id) { 'salesforce123' }
    let(:coda_reference) { 'C012345' }

    subject(:row) do
      Onboard::FrameworkSuppliers::Row.new(
        framework_short_name: framework_short_name,
        lot_number: lot_number,
        supplier_name: supplier_name,
        salesforce_id: salesforce_id,
        coda_reference: coda_reference,
      )
    end

    context 'with a new supplier (i.e. a new salesforce_id)' do
      it 'persists and returns a record for the supplier' do
        supplier = row.onboard!

        expect(supplier).to be_a Supplier
        expect(supplier).to be_persisted
        expect(supplier.name).to eq supplier_name
        expect(supplier.salesforce_id).to eq salesforce_id
        expect(supplier.coda_reference).to eq coda_reference
      end

      it 'creates an active agreement for the supplier and associates it with the lot' do
        supplier = row.onboard!

        expect(supplier.agreements.count).to eq 1
        agreement = supplier.agreements.first
        expect(agreement.framework).to eq framework
        expect(agreement).to be_active
        expect(agreement.framework_lots).to match_array [lot_1]
      end
    end

    context 'when a supplier with same salesforce_id already exists' do
      let!(:matching_supplier) { FactoryBot.create(:supplier, salesforce_id: salesforce_id) }

      it 'doesn’t create a new record' do
        expect { row.onboard! }.not_to change { Supplier.count }
      end

      it 'creates an active agreement for the existing supplier and associates it with the lot' do
        row.onboard!

        expect(matching_supplier.agreements.count).to eq 1
        agreement = matching_supplier.agreements.first
        expect(agreement.framework).to eq framework
        expect(agreement).to be_active
        expect(agreement.framework_lots).to match_array [lot_1]
      end

      context 'and the supplier is already on the framework' do
        context 'and the agreement is active' do
          let!(:matching_agreement) { matching_supplier.agreements.create!(framework: framework) }

          it 'doesn’t create a duplicate agreement' do
            expect { row.onboard! }.not_to change { Agreement.count }
          end

          it 'adds the lot to the supplier’s agreement' do
            row.onboard!

            expect(matching_agreement.framework_lots).to match_array [lot_1]
          end
        end

        context 'and the agreement is inactive' do
          let!(:matching_agreement) do
            matching_supplier.agreements.create!(framework: framework, active: false)
          end

          it 'doesn’t create a duplicate agreement' do
            expect { row.onboard! }.not_to change { Agreement.count }
          end

          it 'adds the lot to the supplier’s agreement and activates the agreement' do
            row.onboard!

            agreement = matching_supplier.agreements.first
            expect(agreement.framework_lots).to match_array [lot_1]
            expect(agreement).to be_active
          end
        end
      end
      context 'and the supplier is already on the framework AND the lot' do
        before do
          matching_agreement = matching_supplier.agreements.create!(framework: framework)
          matching_agreement.framework_lots << lot_1
        end

        it 'doesn’t create a duplicate agreement' do
          expect { row.onboard! }.not_to change { Agreement.count }
        end

        it 'doesn’t create a duplicate agreement_framework_lot' do
          expect { row.onboard! }.not_to change { AgreementFrameworkLot.count }
        end
      end
    end

    context 'with a framework that is not published' do
      before { framework.update(published: false) }

      it 'raises an ActiveRecord::RecordNotFound exception' do
        expect { row.onboard! }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
