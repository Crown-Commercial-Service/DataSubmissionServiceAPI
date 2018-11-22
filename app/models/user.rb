class User < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :suppliers, through: :memberships
  validates :email, presence: true, uniqueness: true
  validates :auth_id, presence: true, uniqueness: true

  def multiple_suppliers?
    suppliers.count > 1
  end
end
