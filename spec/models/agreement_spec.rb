require 'rails_helper'

RSpec.describe Agreement do
  it 'does not allow a supplier to have more than one agreement against the same framework' do
    agreement = FactoryBot.create(:agreement)
    duplicate_agreement = agreement.supplier.agreements.new(framework: agreement.framework)

    expect(duplicate_agreement).not_to be_valid
  end

  it 'can be deactivated' do
    agreement = FactoryBot.create(:agreement, active: true)

    agreement.deactivate!
    expect(agreement).not_to be_active
  end

  it 'can be activated' do
    agreement = FactoryBot.create(:agreement, active: false)

    agreement.activate!
    expect(agreement).to be_active
  end
end
