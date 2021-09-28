class Agreement < ApplicationRecord
  belongs_to :supplier
  belongs_to :framework
  has_many :agreement_framework_lots, dependent: :destroy
  has_many :framework_lots, through: :agreement_framework_lots

  validates :supplier_id, presence: true
  validates :framework_id,
            presence: true,
            uniqueness: { scope: :supplier_id, message: 'agreement already exists for this supplier' }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  def lot_numbers
    framework_lots.pluck(:number)
  end

  def activate!
    update!(active: true)
  end

  def deactivate!
    update!(active: false)
  end
end
