require 'rails_helper'
require 'csv'

RSpec.describe Ingest::Loader do
  subject(:loader) { Ingest::Loader.new(converter, file) }

  describe '#perform' do
    let(:framework) do
      ##
      # RM1043iv doesn't represent the "real" RM1043iv (DOS2) here.
      # It resembles the original RM1043iv but with the addition
      # of the OtherFields (excepting Awarded) from RM3774 for testing only.
      create(:framework, :with_fdl, short_name: 'RM1043iv') do |framework|
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

    let(:fake_other_row) do
      {
        'Campaign Name' => 'Production of 2 Promotional Videos',
        'Customer Organisation' => 'National Crime Agency ',
        'Customer PostCode' => 'SW1H 9HP',
        'Customer URN' => '12345',
        'Date Brief Received' => '2019-12-18',
        'Participated (Y/N)' => 'N',
        'Reason for Non-Participation' => 'Timings meant we could not accommodate brief'
      }
    end

    let(:fake_invoice_row_empty) do
      fake_invoice_row.transform_values { |_| '   ' }.to_h
    end

    let(:fake_order_row_empty) do
      fake_order_row.transform_values { |_| '   ' }.to_h
    end

    let(:invoice_rows) do
      double(
        'Converter::Rows',
        data: [fake_invoice_row.merge('line_number' => '1'), fake_invoice_row.merge('line_number' => '2')],
        row_count: 2,
        sheet_name: 'Invoice Sheet',
        type: 'invoice'
      )
    end

    let(:order_rows) do
      double(
        'Converter::Rows',
        data: [
          fake_order_row.merge('line_number' => '1')
        ],
        row_count: 1,
        sheet_name: 'Contracts',
        type: 'order'
      )
    end

    let(:other_rows) do
      double(
        'Converter::Rows',
        data: [fake_other_row.merge('line_number' => '1')],
        row_count: 1,
        sheet_name: 'Briefs Received',
        type: 'other'
      )
    end

    let(:total_row_count) { invoice_rows.data.count + order_rows.data.count + other_rows.data.count }
    let(:converter) do
      double('converter', total_row_count: total_row_count).tap do |converter|
        allow(converter).to receive(:rows_for).with('invoice').and_return(invoice_rows)
        allow(converter).to receive(:rows_for).with('order').and_return(order_rows)
        allow(converter).to receive(:rows_for).with('other').and_return(other_rows)
      end
    end

    before do
      create(:customer, urn: '12345')

      framework.lots.each do |lot|
        create(:agreement_framework_lot, agreement: agreement, framework_lot: lot)
      end
    end

    context 'everything is valid' do
      it 'loads data from the converter into the database and saves the invoice total' do
        loader.perform

        aggregate_failures do
          expect(file.entries.invoices.count).to eql 2
          expect(file.entries.orders.count).to eql 1
          expect(file.entries.others.count).to eql 1
          expect(file.entries.validated.count).to eql 4

          expect(file.entries.invoices.first.total_value).to eql 12.99
          expect(file.entries.invoices.first.customer_urn).to eql 12345

          expect(file.entries.orders.first.total_value).to eql 22000
          expect(file.entries.orders.first.customer_urn).to eql 12345

          expect(file.submission.invoice_total).to eql 25.98
        end
      end
    end

    context 'there is a gap in the rows between 3 and 5' do
      let(:invoice_rows) do
        double(
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
      end

      it 'ignores that gap and numbers the rows as line_number plus 1' do
        loader.perform

        expect(file.entries.invoices.count).to eql 3

        row_numbers = file.entries.invoices.pluck(:source).map { |source| source['row'] }
        expect(row_numbers).to contain_exactly(4, 6, 7)
      end
    end

    context 'there is a single row that contain only whitespace' do
      let(:invoice_rows) do
        double(
          'rows',
          data: [
            fake_invoice_row.merge('line_number' => '1'),
            fake_invoice_row_empty.merge('line_number' => '2'),
            fake_invoice_row.merge('line_number' => '3'),
          ],
          row_count: 2,
          sheet_name: 'Invoices',
          type: 'invoice'
        )
      end

      it 'ignores that row and counts only the other 2' do
        loader.perform

        expect(file.entries.invoices.count).to eql 2
      end
    end

    context 'A total column has a value of nil' do
      let(:invoice_rows) do
        double(
          'rows',
          data: [
            fake_invoice_row.merge('line_number' => '1', 'Total Charge (Ex VAT)' => 105.22),
            fake_invoice_row.merge('line_number' => '2', 'Total Charge (Ex VAT)' => nil),
          ],
          row_count: 2,
          sheet_name: 'Invoices',
          type: 'invoice'
        )
      end

      it 'calculates the running total even when a total column is nil' do
        loader.perform

        expect(file.submission.invoice_total).to eql 105.22
      end
    end

    context 'the converter rows do not contain all the framework’s invoice attributes' do
      let(:invoice_rows) do
        double(
          'rows',
          data: [
            fake_invoice_row.merge('line_number' => '1').except!('Contract Reference')
          ],
          row_count: 1,
          sheet_name: '',
          type: 'invoice'
        )
      end

      it 'raises MissingColumns' do
        expect { loader.perform }.to raise_error(Ingest::Loader::MissingColumns, /Contract Reference/) do |e|
          expect(e.entry_type).to eql 'invoice'
        end
      end
    end

    context 'the converter rows do not contain all the framework’s order attributes' do
      let(:invoice_rows) do
        double(
          'rows',
          data: [
            fake_invoice_row.merge('line_number' => '1')
          ],
          row_count: 1,
          sheet_name: '',
          type: 'invoice'
        )
      end

      let(:order_rows) do
        double(
          'rows',
          data: [
            fake_order_row.merge('line_number' => '1').except!('Lot Number')
          ],
          row_count: 1,
          sheet_name: '',
          type: 'order'
        )
      end

      it 'raises MissingColumns' do
        expect { loader.perform }.to raise_error(Ingest::Loader::MissingColumns, /Lot Number/) do |e|
          expect(e.entry_type).to eql 'order'
        end
      end
    end

    context 'the converter rows do not contain all the framework’s other attributes' do
      let(:other_rows) do
        double(
          'rows',
          data: [fake_other_row.merge('line_number' => '1').except!('Customer URN')],
          row_count: 1,
          sheet_name: '',
          type: 'other'
        )
      end

      it 'raises MissingColumns' do
        expect { loader.perform }.to raise_error(Ingest::Loader::MissingColumns, /Customer URN/) do |e|
          expect(e.entry_type).to eql 'other'
        end
      end
    end

    context 'the converter rows contains "N/A" in a numeric field' do
      let(:invoice_rows) do
        double(
          'Converter::Rows',
          data: [
            fake_invoice_row.merge('line_number' => '1', 'Price per Unit' => 'N/A'),
            fake_invoice_row.merge('line_number' => '2', 'Price per Unit' => '-'),
          ],
          row_count: 1,
          sheet_name: 'Invoice Sheet',
          type: 'invoice'
        )
      end

      it 'loads data from the converter, marking each row as invalid' do
        loader.perform

        invalid_entries = file.entries.invoices.errored

        aggregate_failures do
          expect(invalid_entries.count).to eql 2

          invalid_entries.each do |entry|
            expect(entry.validation_errors.first).to match a_hash_including('message' => 'is not a number')
          end
        end
      end
    end
  end
end
