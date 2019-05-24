require 'rails_helper'
require 'csv'

RSpec.describe Ingest::Loader do
  describe '#perform' do
    let(:framework) do
      create(:framework, short_name: 'RM1043iv') do |framework|
        framework.lots.create(number: '1')
        framework.lots.create(number: '2')
      end
    end
    let(:supplier) { create(:supplier) }
    let(:submission) { create(:submission, framework: framework, supplier: supplier) }
    let(:file) { create(:submission_file, submission: submission) }
    let!(:agreement) { create(:agreement, framework: framework, supplier: supplier) }

    let(:fake_invoice_row) do
      {
        'SoW / Order Number' => 'TEST0001',
        'Buyer Cost Centre' => '1001',
        'Contract Reference' => 'REF123',
        'Buyer URN' => '12345',
        'Buyer Organisation' => 'Acme Incorporated',
        'Buyer Contact Name' => 'Jo Soap',
        'Buyer Contact Number' => '07234 567890',
        'Buyer Email Address' => 'jo@acme.inc',
        'Invoice Date' => '23/04/2019',
        'Invoice Number' => 'INV1',
        'Lot Number' => '1',
        'Project Phase' => 'phase 1',
        'Project Name' => 'Big Project',
        'Service provided' => 'Security',
        'Location' => 'London',
        'UNSPSC' => '9999',
        'Unit of Purchase' => 'Day',
        'Price per Unit' => '12.99',
        'Quantity' => '1',
        'Total Charge (Ex VAT)' => '12.99',
        'VAT amount charged' => '2.598',
        'Actual Delivery Date SoW complete' => ''
      }
    end

    let(:fake_order_row) do
      {
        'SoW / Order Number' => 'TEST0002',
        'SoW / Order Date' => '28/02/2018',
        'Contract Reference' => '1234',
        'Buyer URN' => '12345',
        'Buyer Organisation' => 'Acme Inc',
        'Buyer Contact Name' => '',
        'Buyer Contact Number' => '',
        'Buyer Email Address' => '',
        'Contract Start Date' => '01/01/2018',
        'Contract End Date' => '01/01/2022',
        'Lot Number' => '2',
        'Project Phase' => 'phase 2',
        'Project Name' => 'Big Project',
        'Service provided' => 'Developer',
        'Location' => 'Norwich',
        'Day Rate' => '550',
        'Quantity' => 40,
        'Total Value' => '22000'
      }
    end

    let(:fake_invoice_row_empty) do
      fake_invoice_row.map { |k, _| [k, '   '] }.to_h
    end

    let(:fake_order_row_empty) do
      fake_order_row.map { |k, _| [k, '   '] }.to_h
    end

    it 'loads data from the converter into the database' do
      create(:customer, urn: '12345')

      framework.lots.each do |lot|
        create(:agreement_framework_lot, agreement: agreement, framework_lot: lot)
      end

      invoice_rows = double(
        'rows',
        data: [fake_invoice_row.merge('line_number' => '1'), fake_invoice_row.merge('line_number' => '2')],
        row_count: 2,
        sheet_name: 'Invoice Sheet',
        type: 'invoice'
      )

      order_rows = double(
        'rows',
        data: [fake_order_row.merge('line_number' => '1')],
        row_count: 1,
        sheet_name: 'Contracts',
        type: 'order'
      )

      converter = double('converter', rows: 3, invoices: invoice_rows, orders: order_rows)

      loader = Ingest::Loader.new(converter, file)

      loader.perform

      expect(file.rows).to eql 3
      expect(file.entries.invoices.count).to eql 2
      expect(file.entries.orders.count).to eql 1
      expect(file.entries.validated.count).to eql 3

      expect(file.entries.invoices.first.total_value).to eql 12.99
      expect(file.entries.invoices.first.customer_urn).to eql 12345

      expect(file.entries.orders.first.total_value).to eql 22000
      expect(file.entries.orders.first.customer_urn).to eql 12345
    end

    it 'ignores empty rows when loading data' do
      invoice_rows = double(
        'rows',
        data: [
          fake_invoice_row.merge('line_number' => '3'),
          fake_invoice_row.merge('line_number' => '5'),
          fake_invoice_row.merge('line_number' => '6'),
        ],
        row_count: 3,
        sheet_name: 'Invoices',
        type: 'invoice'
      )

      order_rows = double(
        'rows',
        data: [
          fake_order_row.merge('line_number' => '1')
        ],
        row_count: 1,
        sheet_name: '',
        type: 'order'
      )

      converter = double('converter', rows: 4, invoices: invoice_rows, orders: order_rows)

      loader = Ingest::Loader.new(converter, file)
      loader.perform

      expect(file.entries.invoices.count).to eql 3

      row_numbers = file.entries.invoices.pluck(:source).map { |source| source['row'] }
      expect(row_numbers).to contain_exactly(4, 6, 7)
    end

    it 'ignores rows that are empty apart from whitespace' do
      invoice_rows = double(
        'rows',
        data: [
          fake_invoice_row.merge('line_number' => '1'),
          fake_invoice_row_empty.merge('line_number' => '2'),
          fake_invoice_row.merge('line_number' => '3'),
        ],
        row_count: 3,
        sheet_name: 'Invoices',
        type: 'invoice'
      )

      order_rows = double(
        'rows',
        data: [
          fake_order_row.merge('line_number' => '1')
        ],
        row_count: 1,
        sheet_name: '',
        type: 'order'
      )

      converter = double('converter', rows: 4, invoices: invoice_rows, orders: order_rows)

      loader = Ingest::Loader.new(converter, file)
      loader.perform

      expect(file.entries.invoices.count).to eql 2
    end

    it 'raises MissingInvoiceColumns if the converter does not contain all the framework’s invoice attributes' do
      invoice_rows = double(
        'rows',
        data: [
          fake_invoice_row.merge('line_number' => '1').except!('Contract Reference')
        ],
        row_count: 1,
        sheet_name: '',
        type: 'invoice'
      )

      order_rows = double(
        'rows',
        data: [
          fake_order_row.merge('line_number' => '1')
        ],
        row_count: 1,
        sheet_name: '',
        type: 'order'
      )

      converter = double('converter', rows: 1, invoices: invoice_rows, orders: order_rows)

      loader = Ingest::Loader.new(converter, file)

      expect { loader.perform }.to raise_error(Ingest::Loader::MissingInvoiceColumns, /Contract Reference/)
    end

    it 'raises MissingOrderColumns if the converter does not contain all the framework’s order attributes' do
      invoice_rows = double(
        'rows',
        data: [
          fake_invoice_row.merge('line_number' => '1')
        ],
        row_count: 1,
        sheet_name: '',
        type: 'invoice'
      )

      order_rows = double(
        'rows',
        data: [
          fake_order_row.merge('line_number' => '1').except!('Lot Number')
        ],
        row_count: 1,
        sheet_name: '',
        type: 'order'
      )

      converter = double('converter', rows: 1, invoices: invoice_rows, orders: order_rows)

      loader = Ingest::Loader.new(converter, file)

      expect { loader.perform }.to raise_error(Ingest::Loader::MissingOrderColumns, /Lot Number/)
    end
  end
end
