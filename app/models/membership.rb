class Membership < ApplicationRecord
  belongs_to :supplier
  belongs_to :user
  validates :user_id, uniqueness: { scope: :supplier_id }
end
