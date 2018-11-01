class User < ApplicationRecord
  has_many :memberships, dependent: :destroy
  validates :email, presence: true, uniqueness: true
  validates :auth_id, presence: true, uniqueness: true
end
