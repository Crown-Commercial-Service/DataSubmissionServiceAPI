class User < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :suppliers, through: :memberships
  validates :email, presence: true, uniqueness: true
  validates :auth_id, presence: true, uniqueness: true

  def self.search(query)
    if query.present?
      joins(:suppliers).where(
        'users.name ILIKE ? OR email ILIKE ? OR suppliers.name ILIKE ?',
        "%#{query}%",
        "%#{query}%",
        "%#{query}%",
      )
    else
      where(nil)
    end
  end

  def multiple_suppliers?
    suppliers.count > 1
  end
end
