require 'rails_helper'

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
        'Contract Reference' => 'REF123',
        'Buyer URN' => '12345',
        'Buyer Organisation' => 'Acme Incorporated',
        'Invoice Date' => '23/04/2019',
        'Invoice Number' => 'INV1',
        'Lot Number' => '1',
        'Project Phase' => 'phase 1',
        'Project Name' => 'Big Project',
        'Service provided' => 'Security',
        'Location' => 'London',
        'UNSPSC' => '9999',
        'Price per Unit' => '12.99',
        'Quantity' => '1',
        'Total Charge (Ex VAT)' => '12.99',
        'VAT amount charged' => '2.598'
      }
    end

    let(:fake_order_row) do
      {
        'SoW / Order Number' => 'TEST0002',
        'SoW / Order Date' => '28/02/2018',
        'Buyer URN' => '12345',
        'Buyer Organisation' => 'Acme Inc',
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
  end
end
