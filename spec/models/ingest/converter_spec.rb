require 'rails_helper'

RSpec.describe Ingest::Converter do
  subject(:converter) { Ingest::Converter.new(download.temp_file.path) }

  let(:download) { fake_download('rm1557-10-test.xls') }

  describe '.invoices' do
    it 'returns a Rows object, which contains the rows from the relevant sheet' do
      invoices = converter.invoices

      expect(invoices).to be_a(Ingest::Converter::Rows)
      expect(invoices.row_count).to eql 1
      expect(invoices.sheet_name).to eql 'InvoicesRaised'
      expect(invoices.type).to eql 'invoice'
      expect(invoices.data).to be_an(Enumerator)

      rows = invoices.data.to_a
      expect(rows.size).to eql 1

      expect(rows[0].to_h).to include(
        'line_number' => '1',
        'Order Reference Number' => 'TEST1234',
        'Customer Unique Reference Number (URN)' => '2526618.0',
        'Customer Organisation Name' => 'Test Organisation',
        'Customer Invoice/Credit Note Date' => '2019-03-01',
        'Customer Invoice/Credit Note Number' => '42.0',
        'Lot Number' => '2.0',
        'Service Group' => 'Operations Management',
        'Digital Marketplace Service ID' => '401234567890123',
        'UNSPSC' => '43231500.0',
        'Unit of Measure' => 'Per User',
        'Price per Unit' => '125000.0',
        'Quantity' => '1.0',
        'Total Cost (ex VAT)' => '125000.0',
        'VAT Amount Charged' => '25000.0',
        'Expenses / Disbursements' => '0.0'
      )
    end

    context 'with a download that has no invoices sheet' do
      let(:download) { fake_download('rm1557viii-with-no-invoices.xls') }

      it 'returns an empty Rows object' do
        allow(Ingest::CommandRunner).to receive(:new).with(/in2csv/).and_call_original

        invoices = converter.invoices

        expect(invoices.data).to be_empty
        expect(invoices.row_count).to eql 0
        expect(invoices.sheet_name).to be_nil
        expect(invoices.type).to be_nil
        expect(Ingest::CommandRunner).to_not have_received(:new).with(/in2csv.*sheet/)
      end
    end
  end

  describe '.orders' do
    it 'returns a Rows object, which contains the rows from the relevant sheet' do
      orders = converter.orders

      expect(orders).to be_a(Ingest::Converter::Rows)
      expect(orders.row_count).to eql 2
      expect(orders.sheet_name).to eql 'Contracts'
      expect(orders.type).to eql 'order'
      expect(orders.data).to be_an(Enumerator)

      rows = orders.data.to_a
      expect(rows.size).to eql 2

      expect(rows[0].to_h).to include(
        'line_number' => '1',
        'Order Reference Number' => '12345678.0',
        'Customer Unique Reference Number (URN)' => '2526618.0',
        'Customer Organisation Name' => 'Test Organisation',
        'Contract Start Date' => '2018-12-25',
        'Contract End Date' => '2020-12-25',
        'Lot Number' => '2.0',
        'Service Group' => 'Collaborative Working',
        'Digital Marketplace Service ID' => '401234567890123',
        'Total Contract Value' => '420000.0'
      )

      expect(rows[1].to_h).to include(
        'line_number' => '2',
        'Order Reference Number' => '98765432.0',
        'Customer Unique Reference Number (URN)' => '2526618.0',
        'Customer Organisation Name' => 'Another Test Organisation',
        'Contract Start Date' => '2019-01-01',
        'Contract End Date' => '2019-06-01',
        'Lot Number' => '1.0',
        'Service Group' => 'Archiving, Backup and Disaster Recovery',
        'Digital Marketplace Service ID' => '401234567890123',
        'Total Contract Value' => '420000.0'
      )
    end

    context 'with a download that has no orders sheet' do
      let(:download) { fake_download('rm3767-with-no-orders.xls') }

      it 'returns an empty Rows object' do
        allow(Ingest::CommandRunner).to receive(:new).with(/in2csv/).and_call_original

        orders = converter.orders

        expect(orders.data).to be_empty
        expect(orders.row_count).to eql 0
        expect(orders.sheet_name).to be_nil
        expect(orders.type).to be_nil
        expect(Ingest::CommandRunner).to_not have_received(:new).with(/in2csv.*sheet/)
      end
    end
  end

  describe '.others' do
    let(:download) { fake_download('RM3774_example_return.xls') }

    it 'has the other rows' do
      others = converter.others

      expected_other_row_count = 5

      expect(others).to be_an(Ingest::Converter::Rows)
      expect(others.row_count).to eql expected_other_row_count
      expect(others.sheet_name).to eql 'Briefs Received'
      expect(others.type).to eql 'other'
      expect(others.data).to be_an(Enumerator)

      rows = others.data.to_a

      order_row_count = 3
      invoice_row_count = 1

      aggregate_failures do
        expect(rows.size).to eql expected_other_row_count

        expect(converter.rows).to eql expected_other_row_count + order_row_count + invoice_row_count

        expect(rows[0].to_h).to include(
          'Awarded (Y/N/In Progress)' => 'N',
          'Campaign Name' => 'Production of 2 Promotional Videos',
          'Customer Organisation' => 'National Crime Agency ',
          'Customer PostCode' => 'SW1H 9HP',
          'Customer URN' => '10018919',
          'Date Brief Received' => '2019-12-18',
          'Participated (Y/N)' => 'N',
          'Reason for Non-Participation' => 'Timings meant we could not accommodate brief',
          'line_number' => '1',
        )
      end
    end
  end

  describe '.rows' do
    it 'returns the total number of rows contained in the Excel file' do
      expect(converter.rows).to eql 3
    end

    context 'with a download that has only one sheet to convert' do
      let(:download) { fake_download('rm3767-with-no-orders.xls') }

      it 'returns the total number of rows contained in the Excel file' do
        expect(converter.rows).to eql 1
      end
    end

    context 'with a download that contains rows containing only whitespace' do
      let(:download) { fake_download('rm3767-with-whitespace-rows.xls') }

      it 'returns the total number of filled rows contained in the Excel file' do
        expect(converter.rows).to eql 2
      end
    end
  end

  describe '.sheets' do
    it 'returns the names of all sheets' do
      expect(converter.sheets).to include('Contracts', 'InvoicesRaised', 'Service Table', 'Lookups')
    end

    context 'with an XLS file from LibreOffice' do
      let(:download) { fake_download('rm1557-10-linux.xls') }

      it 'returns the names of all sheets' do
        expect(converter.sheets).to include('Contracts', 'InvoicesRaised', 'Service Table', 'Lookups')
      end
    end

    context 'with a corrupted XLS file' do
      let(:download) { fake_download('rm1557-10-corrupted.xls') }

      it 'raises UnreadableFile' do
        expect { converter.sheets }.to raise_error(Ingest::Converter::UnreadableFile)
      end
    end
  end

  context 'with a spreadsheet with sheets containing spaces' do
    let(:download) { fake_download('sheet-name-with-spaces.xls') }

    it 'converts the sheet correctly' do
      orders = converter.orders

      expect(orders.row_count).to eql 1
      expect(orders.sheet_name).to eql 'New Call Off Contracts'
      expect(orders.type).to eql 'order'

      expect(orders.data.first['Call Off Contract Reference']).to eql 'a'
    end
  end

  context 'with a spreadsheet that contains empty rows between data' do
    let(:download) { fake_download('rm3787-with-empty-rows.xls') }

    it 'ignores empty rows when calculating row_count' do
      invoices = converter.invoices

      expect(invoices.row_count).to eql 6
    end
  end

  context 'with a spreadsheet whose headers contain erroneous spaces' do
    let(:download) { fake_download('headers-prefixed-with-space.xls') }

    it 'strips those spaces so it is converted correctly' do
      orders = converter.orders

      # NB: header is " Call Off Value" in template
      expect(orders.data.first.headers).to include('Call Off Value')
    end
  end

  context 'with a spreadsheet with a column whose values could be mis-inferred as dates' do
    let(:download) { fake_download('rm1059-with-date-like-value.xls') }

    it 'preserves the string value' do
      invoices = converter.invoices

      expect(invoices.data.first['Product / Service Group Level 2']).to eql('1 Year')
    end
  end

  context 'with a spreadsheet with a column whose values could be mis-inferred as booleans' do
    let(:download) { fake_download('rm6096-with-boolean-like-value.xlsx') }

    it 'preserves the numerical value' do
      invoices = converter.invoices

      expect(invoices.data.first['Lot Number']).to eql('1')
    end
  end
end
