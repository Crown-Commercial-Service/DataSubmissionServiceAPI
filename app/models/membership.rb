class Membership < ApplicationRecord
  belongs_to :supplier
  belongs_to :user, optional: true

  validates :user_id, presence: true
end
