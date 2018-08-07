class Customer < ApplicationRecord
  enum sector: { central_government: 0, wider_public_sector: 1 }

  validates :name, :sector, presence: true
  validates :urn, presence: true, uniqueness: true
end
