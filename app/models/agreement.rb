class Agreement < ApplicationRecord
  belongs_to :supplier
  belongs_to :framework

  validates :supplier_id, presence: true
  validates :framework_id, presence: true
end
