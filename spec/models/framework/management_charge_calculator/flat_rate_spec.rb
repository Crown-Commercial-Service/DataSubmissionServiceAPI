require 'rails_helper'

RSpec.describe Framework::ManagementChargeCalculator::FlatRate do
  let(:calculator) { Framework::ManagementChargeCalculator::FlatRate.new(calculator_arguments) }

  describe '#calculate_for' do
    let(:calculator_arguments) { { percentage: BigDecimal('1.5') } }
    let(:entry) { FactoryBot.build(:submission_entry, total_value: 102123.23) }

    it 'calculates the management charge as a percentage of the total value to 4 decimal places' do
      expect(calculator.calculate_for(entry)).to eql(BigDecimal('1531.8484'))
    end

    context 'with the calculation field overriden' do
      let(:calculator_arguments) { { percentage: BigDecimal('0.5'), column: 'Some field' } }

      context 'and a Float value' do
        let(:entry) { FactoryBot.build(:submission_entry, total_value: 1234, data: { 'Some field' => 548.68 }) }

        it 'correctly calculates and truncates the management charge' do
          expect(calculator.calculate_for(entry)).to eql(BigDecimal('2.7434'))
        end
      end

      context 'and a String value' do
        let(:entry) { FactoryBot.build(:submission_entry, total_value: 1234, data: { 'Some field' => '548.68' }) }

        it 'correctly calculates and truncates the management charge' do
          expect(calculator.calculate_for(entry)).to eql(BigDecimal('2.7434'))
        end
      end

      context 'and an Integer value' do
        let(:entry) { FactoryBot.build(:submission_entry, total_value: 1234, data: { 'Some field' => 200 }) }

        it 'correctly calculates the management charge' do
          expect(calculator.calculate_for(entry)).to eql(BigDecimal('1.0'))
        end
      end
    end
  end
end
