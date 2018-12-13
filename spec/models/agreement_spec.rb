require 'rails_helper'

RSpec.describe Agreement do
  it 'does not allow a supplier to have more than one agreement against the same framework' do
    agreement = FactoryBot.create(:agreement)

    duplicate_agreement = agreement.supplier.agreements.new(framework: agreement.framework)

    expect(duplicate_agreement).not_to be_valid
  end
end
