require 'rails_helper'

RSpec.describe Framework::ManagementChargeCalculator::SectorBased do
  context 'when management charge is based only on sector' do
    let(:calculator) do
      # Comes from an imagined piece of FDL that has both
      # integer and decimal and looks like:
      #
      # ManagementCharge sector_based {
      #   CentralGovernment -> 50%
      #   WiderPublicSector -> 100.0%
      # }
      Framework::ManagementChargeCalculator::SectorBased.new(
        central_government:  Integer('50'),
        wider_public_sector: BigDecimal('100.0')
      )
    end
    let(:data)     { { 'Customer URN' => customer.urn } }
    let(:entry)    { build(:submission_entry, data: data, total_value: 1000, customer_urn: customer.urn) }

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

  context 'when management charge is based on sector and column' do
    let(:calculator) do
      Framework::ManagementChargeCalculator::SectorBased.new(
      central_government: {
        column_names: "Lot Number",
        value_to_percentage: {
          "1": { percentage: BigDecimal(20) }, 
          "2": { percentage: BigDecimal(10) },
          "3": { percentage: BigDecimal(90), column: 'Other Price' }}},
      wider_public_sector: {
        column_names: ['Lot Number', 'Spend Code'],
        value_to_percentage: {
          [Framework::Definition::AST::Any, Framework::Definition::AST::Any] => { percentage: BigDecimal(50) },
          ['2', 'Damages'] => { percentage: BigDecimal(30) }}})
    end

    subject { calculator.calculate_for(entry) }

    context 'central government AND lot 1' do
      let(:customer) { create(:customer, :central_government) }
      let(:entry)    { build(:submission_entry, data: { 'Lot Number': '1' }, total_value: 1000, customer_urn: customer.urn) }

      it { is_expected.to eq(entry.total_value * 0.2) }
    end

    context 'central government AND lot 2' do
      let(:customer) { create(:customer, :central_government) }
      let(:entry)    { build(:submission_entry, data: { 'Lot Number': '2' }, total_value: 1000, customer_urn: customer.urn) }

      it { is_expected.to eq(entry.total_value * 0.1) }
    end

    context 'wider public sector AND lot 2' do
      let(:customer) { create(:customer, :wider_public_sector) }
      let(:entry)    { build(:submission_entry, data: { 'Lot Number': '2', 'Spend Code': 'Damages' }, total_value: 1000, customer_urn: customer.urn) }

      it { is_expected.to eq(entry.total_value * 0.3) }
    end

    context 'wider public sector AND all columns are wildcards' do
      let(:customer) { create(:customer, :wider_public_sector) }
      let(:entry)    { build(:submission_entry, data: { 'Lot Number': '3' }, total_value: 1000, customer_urn: customer.urn) }

      it { is_expected.to eq(entry.total_value * 0.5) }
    end

    context 'central government AND percentage is calculated from another column for a particular lot number' do
      let(:customer) { create(:customer, :central_government) }
      let(:entry)    { build(:submission_entry, data: { 'Lot Number': '3', 'Other Price': 500.00 }, total_value: 1000, customer_urn: customer.urn) }

      it { is_expected.to eq(500 * 0.9) }
    end

  end

  context 'when no fallback wildcard lookup defined' do
    let(:calculator) do
      Framework::ManagementChargeCalculator::SectorBased.new(
        central_government: {
        column_names: "Lot Number",
        value_to_percentage: {
          "1": {percentage: BigDecimal(20)}, "2": {percentage: BigDecimal(10)}}},
      wider_public_sector: {
        column_names: ['Lot Number', 'Spend Code'],
        value_to_percentage: {
          ['1', Framework::Definition::AST::Any] => { percentage: BigDecimal('1.5') }
        }}
      )
    end

    it 'assume zero rate, and report the missing validation lookup to Rollbar' do
      customer = FactoryBot.create(:customer, :wider_public_sector)
      entry = FactoryBot.create(:submission_entry,
                                total_value: 2400.0,
                                customer_urn: customer.urn,
                                data: {
                                  'Lot Number': '3', # There is no lot 3
                                  'Spend Code': 'Other Re-charges'
                                })

      expect(Rollbar).to receive(:error)
      expect(calculator.calculate_for(entry)).to eq(0)
    end
  end
end
