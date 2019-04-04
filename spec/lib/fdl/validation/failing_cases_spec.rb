require 'rails_helper'
require 'fdl/validations/test'

##
# Temporary spec to deal with classes of error found in output
# of fdl:validation:test
RSpec.describe 'Failing cases we found via rake fdl:validation:test' do
  let(:compare)        { FDL::Validations::Test::Compare.new(entry, short_name, fdl_definition) }
  let(:entry)          { build(:submission_entry, data: data) }
  let(:fdl_definition) { Framework::Definition::Language[short_name] }

  let(:supplier)       { double(:supplier) }
  let(:entry)          { double(:submission_entry, submission: submission, data: data) }
  let!(:agreement)     { double(:agreement, supplier: supplier, framework: framework, lot_numbers: [1, 2, 3, 4, 5, 6]) }
  let(:submission)     { double(:submission, supplier: supplier, framework: framework, agreement: agreement) }
  let(:framework)      { double(:framework, short_name: short_name) }
  let!(:lot)           { double(:framework_lot, number: 1, framework: framework) }

  subject(:diff) { compare.diff }

  context 'Framework CM/OSG/05/3565' do
    let(:short_name) { 'CM/OSG/05/3565' }
    let(:data) do
      {
        'Quantity' => 3,
        'Total Spend' => 0.89,
        'Customer URN' => 10038179,
        'Service Type' => 'Linen Hire',
        'Vat Included' => 'Y',
        'Product Group' => 'Old (CMOSG)',
        'Unit Quantity' => 'Each',
        'Price per Item' => 0.2967,
        'Unit of Purchase' => 'EA',
        'Customer Postcode' => 'ST4 6QG',
        'Customer Invoice Date' => '12/31/18',
        'Customer Organisation' => 'University Hospitals of North Staffs',
        'Manufacturers Product Code' => 2322
      }
    end

    # Fixed by: making three fields in the FDL optional
    # and adding support for those optional fields
    it { is_expected.to be_empty }
  end

  context 'Framework RM3754' do
    let(:short_name) { 'RM3754' }
    let(:data)       { { 'Total Charge (ex VAT)' => 13835 } }

    # Fixed by: annotating field kinds properly
    # so we can treat all lookups as if they have type :string
    it { is_expected.to be_empty }
  end

  context 'Framework RM858' do
    let(:short_name) { 'RM858' }

    context 'Lot number problem' do
      let(:data) do
        {
          'UNSPSC' => nil,
          'CAP Code' => 'PEXXXXXXXXXXXX',
          'Fuel Type' => 'Diesel',
          'Lot Number' => 1,
          'Spend Code' => 'Lease Rental',
          'Cost Centre' => 'HEAD OFFICE',
          'Customer URN' => 10004186,
          'Lease Period' => 70,
          'Product Code' => nil,
          'Vehicle Make' => 'Peugeot',
          'Vehicle Type' => nil,
          'Vehicle Model' => 508,
          'Lease End Date' => '3/26/17',
          'Residual Value' => 6200,
          'VAT Applicable' => 'Y',
          'Contract Number' => 314021,
          'Payment Profile' => 'Annual in advance',
          'Lease Start Date' => '3/27/13',
          'Unit of Purchase' => 'per vehicle',
          'Customer PostCode' => 'BS32 4UD',
          'VAT Amount Charged' => 68.51,
          'Vehicle Derivative' => '508 SW Diesel Estate 2.0 HDi 163 Allure 5Dr',
          'CO2 Emission Levels' => 130,
          'Annual Lease Mileage' => 15000,
          'Vehicle Registration' => 'XXXXXXX',
          'Customer Invoice Date' => '12/31/18',
          'Customer Organisation' => 'Agent’s Agency',
          'Invoice Line Quantity' => 1,
          'Price per Unit ex VAT' => 342.56,
          'Supplier Order Number' => nil,
          'Expenses/Disbursements' => nil,
          'Product Classification' => 'Lower Medium',
          'Vehicle Purchase Terms' => 'RM858',
          'Customer Invoice Number' => 199999,
          'Vehicle Conversion Type' => nil,
          'Vehicle Convertors Name' => nil,
          'Base Vehicle Price ex VAT' => 14687.52,
          'Lease Finance Charge ex VAT' => 267.67,
          'Lease Finance Margin ex VAT' => 4.5,
          'Customer Invoice Line Number' => 1,
          'Enhanced Vehicle Discount (%)' => 0,
          'Standard Vehicle Discount (%)' => 29.75,
          'Invoice Line Total Value ex VAT' => 342.56,
          'Customer Order Number / Reference' => nil,
          'Invoice Line Product / Service Grouping' => 'MadeUp Capital',
          'Annual Breakdown & Recovery Costs ex VAT' => 0,
          'Invoice Line Product / Service Description' => 'Car - Lease sourcing',
          'Annual Service Maintenance & Repair Costs ex VAT' => 74.89,
          'Lease Cost excluding Optional Extras and Conversion ex VAT' => 340.29
        }
      end

      ##
      # Error was:
      #   [["-", "Lot Number", "is not included in the supplier framework agreement"]]
      #
      # Fixed by: changing the KnownFields type of LotNumber from :string to :lot_number
      # and adding the LotInAgreementValidator when necessary.
      it { is_expected.to be_empty }
    end

    context 'Spend code problem' do
      let(:data) do
        {
          'Lot Number' => '2',
          'Customer PostCode' => 'BX99 4XX',
          'Customer Organisation' => 'MINISTRY OF TRUTH',
          'Customer URN' => 1999994,
          'Customer Invoice Date' => '12/31/18',
          'Customer Invoice Number' => '59999999',
          'Customer Invoice Line Number' => '1',
          'Invoice Line Product / Service Description' => 'LCV',
          'Unit of Purchase' => 'Each',
          'Price per Unit ex VAT' => nil,
          'Invoice Line Quantity' => '1',
          'Invoice Line Total Value ex VAT' => nil,
          'VAT Applicable' => 'Y',
          'VAT Amount Charged' => nil,
          'Spend Code' => nil,
          'Invoice Line Product / Service Grouping' => 'Automotive Leasing',
          'CAP Code' => 'XXXXXXXXX',
          'Vehicle Make' => 'Fiat',
          'Vehicle Model' => 'Panda',
          'Vehicle Derivative' => 'Cross 0.87',
          'Product Classification' => 'LCV',
          'Vehicle Registration' => 'XXXXXXXX',
          'Vehicle Convertors Name' => 'N/A',
          'Vehicle Conversion Type' => '2-Way Radio/Air conditioning/Bright Orange',
          'Vehicle Type' => 'N/A',
          'Fuel Type' => 'Diesel',
          'CO2 Emission Levels' => '206',
          'Lease Period' => '60',
          'Lease Start Date' => '1/20/16',
          'Lease End Date' => '1/19/21',
          'Payment Profile' => 'Monthly',
          'Annual Lease Mileage' => '20000',
          'Base Vehicle Price ex VAT' => '18276.52',
          'Lease Cost excluding Optional Extras and Conversion ex VAT' => '3732.12',
          'Lease Finance Charge ex VAT' => '3111',
          'Lease Finance Margin ex VAT' => '3.06%',
          'Vehicle Purchase Terms' => 'Buying Solutions Vehicle Purchase Framework RM859',
          'Standard Vehicle Discount (%)' => '28',
          'Enhanced Vehicle Discount (%)' => '0',
          'Annual Service Maintenance & Repair Costs ex VAT' => '646.12',
          'Annual Breakdown & Recovery Costs ex VAT' => '46.2',
          'Residual Value' => '5248.5',
          'Cost Centre' => '2',
          'Contract Number' => '99999'
        }
      end
    end

    context 'All the problems' do
      let(:data) { { 'Contract Number' => 'N/A' } }

      it { is_expected.to be_empty }
    end
  end

  context 'Framework RM6060' do
    let(:short_name) { 'RM6060' }

    context 'dependent field inclusion not working' do
      let(:data) do
        {
          'Fuel Type' => 'Petrol',
          'Lot Number' => 1,
          'Parts Cost' => 0,
          'Vehicle Make' => 'CAPTUR',
          'CO2 Emissions' => 122,
          'Vehicle Model' => 'Renault',
          'Supplier Price' => 10026,
          'Conversion Cost' => 0,
          'Leasing Company' => 'Arnold Clark Vehicle Management',
          'Vehicle Segment' => '4x4/SUV',
          'Vehicle CAP Code' => 'N/A',
          'Total Vehicle Cost' => 13925,
          'MRP Excluding Options' => 13383.33,
          'Customer Support Terms' => 28,
          'Vehicle Trim/Derivative' => '3ICN T90',
          'Additional Support Terms' => 0,
          'eAuction Contract Number' => 'N/A',
          'Customer Organisation Name' => 'London North West Healthcare NHS Trust',
          'Vehicle Registration Number' => 'AX68XEF',
          'Customer Invoice/Credit Note Date' => '1/22/19',
          'Customer Invoice/Credit Note Number' => 'N/A',
          'Customer Unique Reference Number (URN)' => 10042256
        }
      end

      it do
        is_expected.to be_empty
      end
    end

    context 'various optional fields' do
      let(:data) { { 'Lot Number' => 6, 'Parts Cost' => 442301 } }

      it do
        is_expected.to be_empty
      end
    end
  end

  context 'Framework RM3786' do
    let(:short_name) { 'RM3786' }

    context 'Primary Specialism' do
      let(:data) do
        {
          'UNSPSC' => '80120000',
          'Quantity' => '17.6',
          'Matter Name' => 'General Commercial Advice - November 2017- November 2018',
          'Tier Number' => '1',
          'Customer URN' => '10562005',
          'Service Type' => 'Core',
          'Price per Unit' => '182.84',
          'Unit of Purchase' => 'Hourly',
          'Pricing Mechanism' => 'Time and Material',
          'Pro-Bono Quantity' => '0.00',
          'Customer Post Code' => 'SW1H 0ET',
          'Practitioner Grade' => 'Legal Director/Senior Solicitor',
          'Primary Specialism' => 'Contracts',
          'VAT Amount Charged' => '643.60',
          'Total Cost (ex VAT)' => '3217.98',
          'Pro-Bono Total Value' => '0.00',
          'Customer Invoice Date' => '7/5/18',
          'Customer Invoice Number' => '3314793',
          'Pro-Bono Price per Unit' => '0.00',
          'Supplier Reference Number' => '459029.00001',
          'Customer Organisation Name' => 'South Tees Site Company',
          'Sub-Contractor Name (If Applicable)' => 'N/A'
        }
      end

      it do
        is_expected.to be_empty
      end
    end
  end

  describe 'what happens to all the frameworks with empty data' do
    @all_framework_short_names =
      Dir[Rails.root.join('app/models/framework/definition/*.fdl')].map { |filename| File.basename(filename, '.fdl') }

    @all_framework_short_names.each do |fdl_short_name|
      context "nils for #{fdl_short_name}" do
        let(:short_name) { fdl_short_name }
        let(:data)       { {} }

        it { is_expected.to be_empty }
      end
    end
  end
end
