require 'rails_helper'

RSpec.describe SubmissionEntry do
  it { is_expected.to belong_to(:submission) }
  it { is_expected.to belong_to(:submission_file) }

  it { is_expected.to validate_presence_of(:data) }
end
