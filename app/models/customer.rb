class Customer < ApplicationRecord
  enum sector: { central_government: 0, wider_public_sector: 1 }

  has_many :submission_entries,
           :submission_entries_stages,
           primary_key: :urn,
           foreign_key: :customer_urn,
           inverse_of: :customer,
           dependent: :restrict_with_error

  validates :name, :sector, presence: true
  validates :urn, presence: true, uniqueness: true
end
