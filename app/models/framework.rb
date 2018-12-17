class Framework < ApplicationRecord
  has_many :lots, dependent: :nullify, class_name: 'FrameworkLot'
  has_many :submissions, dependent: :nullify

  has_many :agreements, dependent: :destroy
  has_many :suppliers, through: :agreements

  validates :short_name, presence: true, uniqueness: true
  validates :coda_reference, allow_nil: true, format: {
    with: /\A40\d{4}\z/,
    message: 'must start with “40” and have four additional numbers, for example: “401234”'
  }

  delegate :management_charge_rate, to: :definition

  def definition
    @definition ||= Definition[short_name]
  end
end
