class Supplier < ApplicationRecord
  has_many :agreements
  has_many :frameworks, through: :agreements

  validates :name, presence: true
end
