class CustomerEffortScore < ApplicationRecord
  belongs_to :user

  validates :rating, presence: true
  validates :comments, length: { maximum: 2000 }
end
