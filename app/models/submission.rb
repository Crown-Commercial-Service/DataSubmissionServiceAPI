class Submission < ApplicationRecord
  belongs_to :framework
  belongs_to :supplier
  has_many :files, dependent: :nullify, class_name: 'SubmissionFile'
  has_many :entries, dependent: :nullify, class_name: 'SubmissionEntry'
end
