class Membership < ApplicationRecord
  belongs_to :supplier

  validates :supplier_id, presence: true
  validates :user_id, presence: true
end
