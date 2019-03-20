require 'rails_helper'

RSpec.describe Framework::ManagementChargeCalculator::SectorBased do
  let(:calculator) do
    Framework::ManagementChargeCalculator::SectorBased.new(
      central_government: BigDecimal('50'),
      wider_public_sector: BigDecimal('100')
    )
  end
  let(:data)     { { 'Customer URN' => customer.urn } }
  let(:entry)    { build(:submission_entry, data: data, total_value: 1000, customer_urn: customer.urn) }

  describe '#calculate_for' do
    subject { calculator.calculate_for(entry) }

    context 'central government' do
      let(:customer) { create(:customer, :central_government) }

      it { is_expected.to eq(entry.total_value / 2) }
    end

    context 'wider public sector' do
      let(:customer) { create(:customer, :wider_public_sector) }

      it { is_expected.to eq(entry.total_value) }
    end
  end
end
