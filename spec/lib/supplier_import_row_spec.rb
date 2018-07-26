require 'rails_helper'
require './lib/supplier_import_row'

RSpec.describe SupplierImportRow do
  let(:data) do
    {
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
  end

  describe '#initialize' do
    it 'throws an error if the hash is missing required fields' do
      data = {
        frameworkreference: 'RM3756'
      }

      expect { SupplierImportRow.new(data) }.to raise_error('SupplierImportRow::MissingKey')
    end
  end

  describe '#import!' do
    it 'creates a new supplier and adds it to the framework' do
      framework = FactoryBot.create(:framework, short_name: 'RM3756')

      row = SupplierImportRow.new(data)

      expect { row.import! }.to change { Supplier.count }.by(1)

      supplier = Supplier.first
      expect(supplier.name).to eql 'Bob and Bucket LLP'
      expect(supplier.frameworks).to contain_exactly(framework)
    end
  end

  it "doesn't create a supplier, if one already exists with that name" do
    FactoryBot.create(:framework, short_name: 'RM3756')
    FactoryBot.create(:supplier, name: 'Bob and Bucket LLP')

    row = SupplierImportRow.new(data)

    expect { row.import! }.not_to change { Supplier.count }
  end

  it "doesn't create an agreement, if one already exists between the Supplier and Framework" do
    framework = FactoryBot.create(:framework, short_name: 'RM3756')
    supplier = FactoryBot.create(:supplier, name: 'Bob and Bucket LLP')
    FactoryBot.create(:agreement, framework: framework, supplier: supplier)

    row = SupplierImportRow.new(data)

    expect { row.import! }.not_to change { Agreement.count }
  end
end
