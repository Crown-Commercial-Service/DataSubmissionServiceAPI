require 'rails_helper'

RSpec.describe DataWarehouseExport do
  describe 'on creation' do
    context 'with no previous exports' do
      it "sets the new export's range_from to a date before the project started" do
        first_export = DataWarehouseExport.create!

        expect(first_export.range_from).to eql DataWarehouseExport::EARLIEST_RANGE_FROM
      end
    end

    context 'with previous exports' do
      let!(:previous_export) { DataWarehouseExport.create!(range_to: '2018-12-25 12:34:56') }

      it "sets the new export's range_from to the range_to of the most recent export" do
        new_export = DataWarehouseExport.create!

        expect(new_export.range_from).to eql previous_export.range_to
      end
    end

    it "sets the new export's range_to to the current time" do
      freeze_time do
        new_export = DataWarehouseExport.create!
        expect(new_export.range_to).to eql Time.zone.now
      end
    end
  end
end
