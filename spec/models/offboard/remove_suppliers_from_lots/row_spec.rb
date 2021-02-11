require 'rails_helper'

RSpec.describe Offboard::RemoveSuppliersFromLots::Row do
  describe '#offboard!' do
    let!(:framework) { FactoryBot.create(:framework) }
    let(:framework_short_name) { framework.short_name }

    let!(:lot_1) { framework.lots.create!(number: '1') }
    let!(:lot_2) { framework.lots.create!(number: '2') }
    let(:lot_number) { lot_1.number }

    let(:supplier_name) { 'Big Dog Limited' }
    let(:salesforce_id) { 'salesforce123' }

    let!(:supplier) do
      supplier = create(:supplier,
                        name: supplier_name,
                        salesforce_id: salesforce_id)

      agreement = supplier.agreements.create!(framework: framework)

      agreement.agreement_framework_lots.create!(framework_lot: lot_1)

      supplier
    end

    subject(:row) do
      Offboard::RemoveSuppliersFromLots::Row.new(
        framework_short_name: framework_short_name,
        lot_number: lot_number,
        supplier_name: supplier_name,
        salesforce_id: salesforce_id,
      )
    end

    context 'with an existing supplier' do
      context 'when the supplier will still be on at least one lot' do
        before do
          supplier.agreements.first.agreement_framework_lots.create(framework_lot: lot_2)
        end

        it 'removes it from the lot' do
          row.offboard!

          agreement = supplier.agreements.first
          expect(agreement.framework).to eq framework
          expect(agreement).to be_active
          expect(agreement.framework_lots).to match_array [lot_2]
        end
      end

      context 'when the supplier will be removed from all lots' do
        it 'removes it from the lot and deactivates the agreement' do
          row.offboard!

          agreement = supplier.agreements.first
          expect(agreement.framework_lots).to be_empty
          expect(agreement).not_to be_active
        end
      end
    end

    context 'with a framework that is not published' do
      before { framework.update(published: false) }

      it 'raises an ActiveRecord::RecordNotFound exception' do
        expect { row.offboard! }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
