class Agreement < ApplicationRecord
  belongs_to :supplier
  belongs_to :framework
end
