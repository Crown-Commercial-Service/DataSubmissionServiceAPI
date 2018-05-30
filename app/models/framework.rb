class Framework < ApplicationRecord
  has_many :lots, dependent: :nullify, class_name: 'FrameworkLot'

  has_many :agreements, dependent: :destroy
  has_many :suppliers, through: :agreements

  validates :short_name, presence: true, uniqueness: true
end
