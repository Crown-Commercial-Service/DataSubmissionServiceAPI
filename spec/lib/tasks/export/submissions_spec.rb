require 'rails_helper'

RSpec.describe 'rake export:submissions', type: :task do
  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  context 'no date is given' do
    let(:submission_exporter)   { spy('Export::Submissions') }
    let(:submissions_to_export) { [double('Submission'), double('Submission')] }
    let(:todays_filename)       { "/tmp/submissions_#{Time.zone.today}.csv" }

    after { File.delete(todays_filename) }

    before do
      allow(Export::Submissions::Extract).to receive(:all_relevant).and_return(submissions_to_export)
      allow(Export::Submissions).to receive(:new).with(
        submissions_to_export, duck_type(:puts)
      ).and_return(
        submission_exporter
      )

      task.execute
    end

    it 'forwards the request to Export::Submissions#run' do
      expect(submission_exporter).to have_received(:run)
    end

    it 'creates that file' do
      expect(File).to exist(todays_filename)
    end

    it 'tells us what file it’s creating on STDERR' do
      expect { task.execute }.to output(
        "Exporting submissions to #{todays_filename}\n"
      ).to_stderr
    end
  end
end
