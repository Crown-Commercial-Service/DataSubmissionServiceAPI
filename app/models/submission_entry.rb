class SubmissionEntry < ApplicationRecord
  belongs_to :submission
  belongs_to :submission_file, optional: true

  validates :data, presence: true
end
