class Agreement < ApplicationRecord
  belongs_to :supplier
  belongs_to :framework
  has_many :agreement_framework_lots, dependent: :destroy
  has_many :framework_lots, through: :agreement_framework_lots

  validates :supplier_id, presence: true
  validates :framework_id, presence: true
end
