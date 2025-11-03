require 'rails_helper'

RSpec.describe Onboard::FrameworkSuppliers do
  it 'raises an error if the expected headers are not present' do
    bad_headers_csv_path = Rails.root.join('spec', 'fixtures', 'framework_suppliers_bad_headers.csv')

    expect { Onboard::FrameworkSuppliers.new(bad_headers_csv_path) }.to raise_error(
      ArgumentError, /Missing headers in CSV file: salesforce_id/
    )
  end

  describe '#run' do
    let(:csv_path) { Rails.root.join('spec', 'fixtures', 'framework_suppliers.csv') }
    let(:onboarder) { Onboard::FrameworkSuppliers.new(csv_path, logger: Logger.new('/dev/null')) }

    let!(:framework) do
      FactoryBot.create(:framework, short_name: 'RM123') do |framework|
        framework.lots.create!(number: '1')
        framework.lots.create!(number: '2')
      end
    end

    it 'on-boards the suppliers' do
      expect { onboarder.run }.to change { Supplier.count }.by 2
    end

    context 'when there is bad data in the CSV' do
      let(:csv_path) { Rails.root.join('spec', 'fixtures', 'framework_suppliers_with_errors.csv') }

      it 'rolls back any changes to the database' do
        supplier_count_before = Supplier.count

        expect { onboarder.run }.to raise_error(ActiveRecord::RecordInvalid)

        expect(Supplier.count).to eq supplier_count_before
      end
    end

    context 'when the CSV references a framework that is not published' do
      let(:csv_path) { Rails.root.join('spec', 'fixtures', 'framework_suppliers.csv') }

      before { framework.update!(aasm_state: 'archived') }

      it 'rolls back any changes to the database' do
        supplier_count_before = Supplier.count

        expect { onboarder.run }.to raise_error(ActiveRecord::RecordNotFound)

        expect(Supplier.count).to eq supplier_count_before
      end
    end
  end
end
