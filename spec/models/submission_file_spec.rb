require 'rails_helper'

RSpec.describe SubmissionFile do
  it { is_expected.to belong_to(:submission) }
end
