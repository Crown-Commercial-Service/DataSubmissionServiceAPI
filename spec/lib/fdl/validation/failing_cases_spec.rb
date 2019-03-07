require 'rails_helper'
require 'fdl/validations/test'

##
# Temporary spec to deal with classes of error found in output
# of fdl:validation:test
RSpec.describe 'Failing cases we found via rake fdl:validation:test' do
  let(:compare)  { FDL::Validations::Test::Compare.new(entry, short_name) }
  let(:entry)    { build(:submission_entry, data: data) }

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
end