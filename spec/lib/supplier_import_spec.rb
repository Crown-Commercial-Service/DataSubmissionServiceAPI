require 'rails_helper'
require './lib/supplier_import'
require './lib/supplier_import_row'

RSpec.describe SupplierImport do
  describe '#initialize' do
    it 'accepts CSV data as a string input' do
      csv = "frameworkreference,suppliername\nRM1234,Cheese & Crackers LLP\nRM5678,Vaughan Legal\n"

      expect { SupplierImport.new(csv) }.to_not raise_error
    end
  end

  describe '#run!' do
    it 'creates supplier records for the suppliers listed in the CSV data' do
      rm1234 = FactoryBot.create(:framework, short_name: 'RM1234')
      rm5678 = FactoryBot.create(:framework, short_name: 'RM5678')

      csv = "frameworkreference,suppliername\nRM1234,Cheese & Crackers LLP\nRM5678,Vaughan Legal\n"

      SupplierImport.new(csv).run!

      created_suppliers = Supplier.order(:name).all

      expect(created_suppliers[0].name).to eql 'Cheese & Crackers LLP'
      expect(created_suppliers[0].frameworks).to contain_exactly(rm1234)

      expect(created_suppliers[1].name).to eql 'Vaughan Legal'
      expect(created_suppliers[1].frameworks).to contain_exactly(rm5678)
    end
  end
end
