class Membership < ApplicationRecord
  belongs_to :supplier

  validates :user_id, presence: true
end
