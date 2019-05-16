class UrnList < ApplicationRecord
  include AASM

  aasm do
    state :pending, initial: true
    state :processed
    state :failed
  end

  has_one_attached :excel_file

  def file_key
    excel_file&.attachment&.key
  end
end
