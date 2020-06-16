require 'rails_helper'

RSpec.describe Offboard::FrameworkSuppliers::Row do
  describe '#offboard!' do
    let!(:framework) { FactoryBot.create(:framework) }
    let(:framework_short_name) { framework.short_name }

    let!(:lot_1) { framework.lots.create!(number: '1') }
    let!(:lot_2) { framework.lots.create!(number: '2') }
    let(:lot_number) { lot_1.number }

    let(:supplier_name) { 'Big Dog Limited' }
    let(:salesforce_id) { 'salesforce123' }
    let(:coda_reference) { 'C012345' }

    let!(:supplier) do
      supplier = create(:supplier,
                        name: supplier_name,
                        salesforce_id: salesforce_id,
                        coda_reference: coda_reference)

      agreement = supplier.agreements.create!(framework: framework)

      [lot_1, lot_2].each do |lot|
        agreement.agreement_framework_lots.create!(framework_lot: lot)
      end

      supplier
    end

    subject(:row) do
      Offboard::FrameworkSuppliers::Row.new(
        framework_short_name: framework_short_name,
        lot_number: lot_number,
        supplier_name: supplier_name,
        salesforce_id: salesforce_id,
        coda_reference: coda_reference,
      )
    end

    context 'with an existing supplier' do
      it 'disassociates it from the lot' do
        row.offboard!

        agreement = supplier.agreements.first
        expect(agreement.framework).to eq framework
        expect(agreement).to be_active
        expect(agreement.framework_lots).to match_array [lot_2]
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
