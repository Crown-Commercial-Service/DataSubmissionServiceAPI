class SubmissionFile < ApplicationRecord
  belongs_to :submission
  has_many :entries, dependent: :nullify, class_name: 'SubmissionEntry'

  has_one_attached :file

  def filename
    file.attachment.filename.to_s if file.attached?
  end

  def temporary_download_url
    Rails.application.routes.url_helpers.rails_blob_url(file.attachment) if file.attached?
  end

  def file_key
    file.attachment.key.to_s if file.attached?
  end
end
