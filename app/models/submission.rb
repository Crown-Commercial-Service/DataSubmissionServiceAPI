class Submission < ApplicationRecord
  belongs_to :framework
  belongs_to :supplier
  has_many :files, dependent: :nullify, class_name: 'SubmissionFile'
end
