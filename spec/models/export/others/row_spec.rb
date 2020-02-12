require 'rails_helper'

RSpec.describe Export::Others::Row do
  let(:framework)     { create :framework, :with_fdl, short_name: 'RM3774' }
  let(:submission_id) { 'd458a903-1b69-4062-8d54-f1039d1d4c13' }
  let(:submission)    { create :submission, id: submission_id, framework: framework }

  let(:entry) do
    build(:other_entry, submission: submission, data: data) do |entry|
      # For performance, extracts project a _framework_short_name field onto
      # each row. Simulate that in a non-RSpec-worrying way here
      entry.define_singleton_method :_framework_short_name do
        entry.submission.framework.short_name
      end
    end
  end

  let(:data) do
    {
      'Customer URN' => 12345,
      'Customer PostCode' => 'SW1 1AA',
      'Customer Organisation' => 'Customer name',
      'Campaign Name' => 'Campy',
      'Date Brief Received' => Date.new(2020, 12, 31),
      'Participated (Y/N)' => 'Y',
      'Awarded (Y/N/In Progress)' => 'N',
      'Reason for Non-Participation' => 'At dentist'
    }
  end

  subject(:csv_line) { Export::Others::Row.new(entry, {}).to_csv_line }

  it {
    is_expected.to eql(
      "#{submission_id},12345,Customer name,,,,Campy,,,,,2020-12-31,Y,N,At dentist,,,,,,,,,,,,,,,,,,,,\n"
    )
  }
end
