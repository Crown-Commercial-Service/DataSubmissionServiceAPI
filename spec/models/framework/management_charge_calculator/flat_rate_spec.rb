require 'rails_helper'

RSpec.describe Framework::ManagementChargeCalculator::FlatRate do
  it 'calculates the management charge for an entry, using a flat rate' do
    entry = FactoryBot.create(:submission_entry, total_value: 180)
    calculator = Framework::ManagementChargeCalculator::FlatRate.new(percentage: 5)

    expect(calculator.calculate_for(entry)).to eql(9) # 5% of 180 = 9
  end
end
