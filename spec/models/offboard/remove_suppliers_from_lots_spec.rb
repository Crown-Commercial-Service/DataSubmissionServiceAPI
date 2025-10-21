require 'rails_helper'

RSpec.describe Offboard::RemoveSuppliersFromLots do
  it 'raises an error if the expected headers are not present' do
    bad_headers_csv_path = Rails.root.join('spec', 'fixtures', 'framework_suppliers_bad_headers.csv')

    expect { Offboard::RemoveSuppliersFromLots.new(bad_headers_csv_path) }.to raise_error(
      ArgumentError, /Missing headers in CSV file: salesforce_id/
    )
  end

  describe '#run' do
    let(:csv_path) { Rails.root.join('spec', 'fixtures', 'suppliers-to-offboard-from-framework-lots.csv') }
    let(:offboarder) { Offboard::RemoveSuppliersFromLots.new(csv_path, logger: Logger.new('/dev/null')) }

    let!(:framework) do
      FactoryBot.create(:framework, short_name: 'FM1234')
    end

    let(:lot_1) { framework.lots.create!(number: '1') }
    let(:lot_2a) { framework.lots.create!(number: '2a') }

    let!(:supplier) do
      FactoryBot.create(:supplier, salesforce_id: '001b000003FAKEFAKE')
    end

    let!(:agreement) do
      FactoryBot.create(:agreement, supplier: supplier, framework: framework) do |agreement|
        [lot_1, lot_2a].each do |framework_lot|
          agreement.agreement_framework_lots.create!(framework_lot: framework_lot)
        end
      end
    end

    it 'offboards the suppliers' do
      expect { offboarder.run }.to change { agreement.agreement_framework_lots.count }.by(-1)
    end

    context 'when the CSV references a framework that is not published' do
      it 'raises an error' do
        framework.update(aasm_state: 'archived')

        expect { offboarder.run }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
