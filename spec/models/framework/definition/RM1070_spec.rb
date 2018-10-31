require 'rails_helper'

RSpec.describe Framework::Definition::RM1070 do
  let(:customer) { FactoryBot.create(:customer) }

  describe Framework::Definition::RM1070::Invoice do
    # rubocop:disable Metrics/LineLength
    let(:valid_params) do
      {
        'UNSPSC' => 25101503,
        'Quantity' => 1,
        'Fuel Type' => 'DIESEL',
        'Lot Number' => 7,
        'Cost Centre' => 'N/A',
        'Customer URN' => customer.urn,
        'Vehicle Make' => 'Vauxhall',
        'CO2 Emissions' => 101,
        'Vehicle Model' => 'Astra 16',
        'Invoice Number' => 787908,
        'Contract Number' => 'RM1070',
        'Leasing Company' => 'N/A',
        'VAT Applicable?' => 'Y',
        'Vehicle Segment' => 'Lower Medium',
        'Unit of Purchase' => 'Each',
        'Vehicle CAP Code' => 'VAAS16DFS5HDTM 7',
        'Customer PostCode' => 'BS11 0YH',
        'VAT amount charged' => 0.2,
        'Invoice Line Number' => 1,
        'eAuction Contract No' => 'N/A',
        'Customer Invoice Date' => '9/11/18',
        'Customer Organisation' => 'Avon & Somerset [Police]',
        'Customer Support Terms' => 40,
        'Vehicle Trim/Derivative' => 'Astra 5 Dr Sports Tourer Police 1.6Cdti (136Ps) S/S 6 Speed',
        'Invoice Price Per Vehicle' => 10530.23,
        'Vehicle Registration Number' => 'WX18BCU',
        'List Price Excluding Options' => 16495.83,
        'Invoice Price Excluding Options' => 9897.5,
        'Additional Expenditure to provide goods' => 0,
        'Additional support terms given to Lease companies' => 'N/A',
        'All Conversion and third party conversion costs excluding factory fit options' => 1012.71,
        'Total Supplier price including standard factory fit options but excluding conversion costs and work ex VAT' => 10530.23
      }
    end
    # rubocop:enable Metrics/LineLength

    it 'validates valid invoice entry data' do
      invoice = Framework::Definition::RM1070::Invoice.new_from_params(valid_params)

      expect(invoice).to be_valid
    end

    describe '"VAT Applicable?" field' do
      it 'only validates "Y" or "N"' do
        invoice = invoice_from_params('VAT Applicable?' => 'Y')
        expect(invoice).to be_valid
        expect(invoice.attributes['VAT Applicable?']).to eq 'Y'

        invoice = invoice_from_params('VAT Applicable?' => 'N')
        expect(invoice).to be_valid
        expect(invoice.attributes['VAT Applicable?']).to eq 'N'

        invoice = invoice_from_params('VAT Applicable?' => 'Yes')
        expect(invoice).not_to be_valid
        expect(invoice.errors['VAT Applicable?'].first).to match("Enter 'Y' or 'N'")

        invoice = invoice_from_params('VAT Applicable?' => true)
        expect(invoice).not_to be_valid
        expect(invoice.errors['VAT Applicable?'].first).to match("Enter 'Y' or 'N'")
      end
    end

    describe '"Customer Invoice Date" field' do
      it 'validates as an ingested date field' do
        ['9/14/18', '9/10/17', '12/10/2018', '30/10/2019'].each do |valid_date_string|
          expect(invoice_from_params('Customer Invoice Date' => valid_date_string)).to be_valid
        end

        ['13/10/18', '12/20/2018', 'Bob'].each do |bad_date_string|
          invoice = invoice_from_params('Customer Invoice Date' => bad_date_string)
          expect(invoice).not_to be_valid
          expect(invoice.errors['Customer Invoice Date'].first)
            .to eq('must be in the format dd/mm/yyyy')
        end
      end
    end

    def invoice_from_params(overrides)
      Framework::Definition::RM1070::Invoice.new_from_params valid_params.merge(overrides)
    end
  end
end
