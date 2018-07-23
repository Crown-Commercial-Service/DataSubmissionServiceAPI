require 'rails_helper'
require './lib/supplier_import_row'

RSpec.describe SupplierImportRow do
  describe '#import!' do
    it 'creates a new supplier and adds it to the framework' do
      framework = FactoryBot.create(:framework, short_name: 'RM3756')

      data = {
        frameworkreference: 'RM3756',
        supplierid: 1234,
        suppliername: 'Bob and Bucket LLP',
        lotid: 5678,
        lotnumber: 1,
        username: 'francis.brown',
        personname: 'Francis Brown',
        jobtitle: 'Big Cheese',
        contacttel: '02088118055',
        contactmobile: '07900111222',
        email: 'francis.brown@example.com',
        usercreationdate: '1/1/1970 18:00',
        lastlogindate: '1/7/2018 12:40'
      }

      row = SupplierImportRow.new(data)

      expect { row.import! }.to change { Supplier.count }.by(1)

      supplier = Supplier.first
      expect(supplier.name).to eql 'Bob and Bucket LLP'
      expect(supplier.frameworks).to contain_exactly(framework)
    end
  end
end
