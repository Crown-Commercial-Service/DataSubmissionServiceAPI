class Task < ApplicationRecord
  validates :status, presence: true
end
