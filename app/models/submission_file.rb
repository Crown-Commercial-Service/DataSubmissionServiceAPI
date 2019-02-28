class SubmissionFile < ApplicationRecord
  belongs_to :submission
  has_many :entries, dependent: :nullify, class_name: 'SubmissionEntry'

  has_one_attached :file

  def filename
    file.attachment.filename.to_s if file.attached?
  end
end
