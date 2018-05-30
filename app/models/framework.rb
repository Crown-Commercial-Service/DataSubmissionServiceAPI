class Framework < ApplicationRecord
  has_many :lots, dependent: :nullify, class_name: 'FrameworkLot'

  validates :short_name, presence: true, uniqueness: true
end
