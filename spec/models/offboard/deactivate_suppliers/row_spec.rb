require 'rails_helper'

RSpec.describe Offboard::DeactivateSuppliers::Row do
  describe '#offboard!' do
    let!(:framework) { FactoryBot.create(:framework) }
    let(:framework_short_name) { framework.short_name }

    let(:supplier_name) { 'Big Dog Limited' }
    let(:salesforce_id) { 'salesforce123' }
    let(:coda_reference) { 'C012345' }

    let!(:supplier) do
      supplier = create(:supplier,
                        name: supplier_name,
                        salesforce_id: salesforce_id,
                        coda_reference: coda_reference)

      supplier.agreements.create!(framework: framework)

      supplier
    end

    subject(:row) do
      Offboard::DeactivateSuppliers::Row.new(
        framework_short_name: framework_short_name,
        supplier_name: supplier_name,
        salesforce_id: salesforce_id,
        coda_reference: coda_reference,
      )
    end

    context 'with an existing supplier' do
      it 'deactivates the agreement' do
        row.offboard!

        agreement = supplier.agreements.first
        expect(agreement).not_to be_active
      end
    end

    context 'with a framework that is not published' do
      before { framework.update(published: false) }

      it 'raises an ActiveRecord::RecordNotFound exception' do
        expect { row.offboard! }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when there is no agreement' do
      before { framework.update(agreements: []) }

      it 'raises an ActiveRecord::RecordNotFound exception' do
        expect { row.offboard! }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
