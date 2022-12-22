class BulkUserUpload < ApplicationRecord
  include AASM

  aasm do
    state :pending, initial: true
    state :processed
    state :failed
  end
  
  has_one_attached :csv_file
end
