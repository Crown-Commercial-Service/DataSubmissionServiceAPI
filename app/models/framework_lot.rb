class FrameworkLot < ApplicationRecord
  belongs_to :framework
  has_many :agreement_framework_lots
  has_many :agreements, through: :agreement_framework_lots

  validates :number, presence: true, uniqueness: { scope: :framework_id }

  def has_active_agreement?
    agreements.where(active: true).any?
  end
end
