class Supplier < ApplicationRecord
  has_many :agreements, dependent: :destroy
  has_many :frameworks, through: :agreements
  has_many :submissions, dependent: :nullify
  has_many :tasks, inverse_of: :supplier, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  validates :name, presence: true
  validates :coda_reference, allow_nil: true, format: {
    with: /\AC0\d{5}\z/,
    message: 'must start with “C0” and have five additional numbers, for example: “C012345”'
  }

  scope :excluding, ->(suppliers) { where.not(id: suppliers) }
end
