require 'rails_helper'

RSpec.describe Offboard::DeactivateSuppliers do
  it 'raises an error if the expected headers are not present' do
    bad_headers_csv_path = Rails.root.join(
      'spec', 'fixtures', 'suppliers-to-offboard-from-frameworks-bad-headers.csv'
    )

    expect { Offboard::DeactivateSuppliers.new(bad_headers_csv_path) }.to raise_error(
      ArgumentError, /Missing headers in CSV file: salesforce_id/
    )
  end

  describe '#run' do
    let(:csv_path) { Rails.root.join('spec', 'fixtures', 'suppliers-to-offboard-from-frameworks.csv') }
    let(:offboarder) { Offboard::DeactivateSuppliers.new(csv_path, logger: Logger.new('/dev/null')) }

    let!(:framework) do
      FactoryBot.create(:framework, short_name: 'FM1234')
    end

    let!(:supplier) do
      FactoryBot.create(:supplier, salesforce_id: '001b000003FAKEFAKE')
    end

    let!(:agreement) do
      FactoryBot.create(:agreement, supplier: supplier, framework: framework)
    end

    it 'deactivates the agreements' do
      expect { offboarder.run }.to change { Agreement.where(active: true).count }.by(-1)
    end

    context 'when the CSV references a framework that is not published' do
      it 'raises an error' do
        framework.update(aasm_state: 'archived')

        expect { offboarder.run }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
