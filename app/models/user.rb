require './lib/auth0_api'

class User < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :suppliers, through: :memberships
  has_many :submissions, through: :suppliers
  has_many :agreements, through: :suppliers
  has_many :tasks, through: :suppliers
  has_many :customer_effort_scores, dependent: :nullify
  validates :name, presence: true
  validates :email, email: { mode: :strict }, presence: true, uniqueness: { case_sensitive: false }

  scope :active, -> { where.not(auth_id: nil) }
  scope :inactive, -> { where(auth_id: nil) }

  def name=(value)
    super value.squish
  end

  def email=(value)
    super value.squish
  end

  def self.search(query)
    if query.present?
      eager_load(:suppliers)
        .where('users.name ILIKE :query OR email ILIKE :query OR suppliers.name ILIKE :query', query: "%#{query}%")
    else
      where(nil)
    end
  end

  def multiple_suppliers?
    suppliers.count > 1
  end

  def active?
    !auth_id.nil?
  end
end
