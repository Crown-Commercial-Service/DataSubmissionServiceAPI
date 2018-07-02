class Task < ApplicationRecord
  validates :status, presence: true

  belongs_to :framework, optional: true
  belongs_to :supplier
end
