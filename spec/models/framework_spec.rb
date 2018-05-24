require 'rails_helper'

RSpec.describe Framework do
  it { is_expected.to have_many(:lots) }
end
