require 'rails_helper'

RSpec.describe Rails::Application do
  def record_counts
    [Framework, Supplier, Agreement, Task, Submission, SubmissionFile].map(&:count)
  end

  context 'seeds have not yet been loaded' do
    it 'loads our seed data successfully' do
      expect { Rails.application.load_seed }.to change { record_counts }
    end
  end

  context 'seeds have already been loaded' do
    before { Rails.application.load_seed }

    it 'succeeds, without creating any new records' do
      expect { Rails.application.load_seed }.to_not change { record_counts }
    end
  end
end
