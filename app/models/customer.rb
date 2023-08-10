class Customer < ApplicationRecord
  enum sector: { central_government: 0, wider_public_sector: 1 }

  has_many :submission_entries,
           primary_key: :urn,
           foreign_key: :customer_urn,
           inverse_of: :customer,
           dependent: :restrict_with_error

  has_many :submission_entries_stages,
           primary_key: :urn,
           foreign_key: :customer_urn,
           inverse_of: :customer,
           dependent: :restrict_with_error

  validates :name, :sector, presence: true
  validates :urn, presence: true, uniqueness: true

  def self.search(query)
    if query.blank?
      all
    else
      where('cast(urn as text) ILIKE :query OR name ILIKE :query OR postcode ILIKE :query',
            query: "%#{query}%")
    end
  end
end
