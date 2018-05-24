class Framework < ApplicationRecord
  has_many :lots, dependent: :nullify, class_name: 'FrameworkLot'
end
