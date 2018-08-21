class SubmissionFile < ApplicationRecord
  belongs_to :submission
  has_many :entries, dependent: :nullify, class_name: 'SubmissionEntry'

  has_one_attached :file
end
