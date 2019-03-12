require 'rails_helper'

RSpec.describe Framework::ManagementChargeCalculator::ColumnBased do
  it 'calculates the management charge for an entry, based on the value of a given column' do
    entry = FactoryBot.create(:submission_entry, total_value: 123.45, data: { test_value: 'test' })

    calculator = Framework::ManagementChargeCalculator::ColumnBased.new(
      varies_by: 'test_value',
      value_to_percentage: {
        'other': 0,
        'test': BigDecimal('10')
      }
    )

    expect(calculator.calculate_for(entry)).to eq(12.345) # 10% of 123.45
  end

  it 'handles column values that have a different case to the rule' do
    entry = FactoryBot.create(:submission_entry, total_value: 123.45, data: { test_value: 'TeST' })

    calculator = Framework::ManagementChargeCalculator::ColumnBased.new(
      varies_by: 'test_value',
      value_to_percentage: {
        'Test': BigDecimal('5')
      }
    )

    expect(calculator.calculate_for(entry)).to eq(6.1725) # 5% of 123.45
  end

  it 'rounds to four decimal places' do
    entry = FactoryBot.create(:submission_entry, total_value: 42.424242, data: { test_value: 'test' })

    calculator = Framework::ManagementChargeCalculator::ColumnBased.new(
      varies_by: 'test_value',
      value_to_percentage: {
        'test': BigDecimal('0.5')
      }
    )

    expect(calculator.calculate_for(entry)).to eq(0.2121) # 0.5% of 123.45
  end

  it 'when the lookup fails, which should have been caught by validation, assume zero rate' do
    entry = FactoryBot.create(:submission_entry, total_value: 42.424242, data: { test_value: 'invalid' })

    calculator = Framework::ManagementChargeCalculator::ColumnBased.new(
      varies_by: 'test_value',
      value_to_percentage: {
        'test': BigDecimal('0.5')
      }
    )

    expect(Rollbar).to receive(:error)
    expect(calculator.calculate_for(entry)).to eq(0)
  end
end
