class Supplier < ApplicationRecord
  has_many :agreements, dependent: :destroy
  has_many :frameworks, through: :agreements
  has_many :submissions, dependent: :nullify

  validates :name, presence: true
end
