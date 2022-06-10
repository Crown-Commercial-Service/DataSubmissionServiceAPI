require 'rails_helper'

RSpec.describe CustomerEffortScore, type: :model do
  subject { FactoryBot.create(:customer_effort_score) }

  it { is_expected.to belong_to(:user) }
end
