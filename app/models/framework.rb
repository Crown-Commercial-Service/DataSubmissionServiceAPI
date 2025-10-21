class Framework < ApplicationRecord
  include AASM

  aasm column: 'aasm_state' do
    state :new, initial: true
    state :published
    state :archived

    event :publish do
      transitions from: %i[new archived], to: :published, guard: :load_lots!
    end
    event :archive do
      transitions from: %i[published], to: :archived
    end
  end

  has_many :lots, dependent: :nullify, class_name: 'FrameworkLot'
  has_many :submissions, dependent: :nullify

  has_many :agreements, dependent: :destroy
  has_many :suppliers, through: :agreements

  validates :name, :definition_source, presence: true
  validates :short_name, presence: true, uniqueness: true

  validates :definition_source, fdl: true, allow_nil: true

  scope :published, -> { where(aasm_state: 'published') }
  scope :archived, -> { where(aasm_state: 'archived') }
  scope :new_state, -> { where(aasm_state: 'new') }

  has_one_attached :template_file

  def full_name
    "#{short_name} #{name}"
  end

  def definition
    @definition ||= Definition[short_name]
  end

  def file_key
    template_file&.attachment&.key
  end

  def file_name
    template_file&.attachment&.filename
  end

  def self.new_from_fdl(definition_source)
    Framework.new(definition_source: definition_source).tap do |framework|
      generator = Framework::Definition::Generator.new(definition_source, Rails.logger)

      if generator.success?
        framework.name       = generator.definition.framework_name
        framework.short_name = generator.definition.framework_short_name
      else
        framework.errors.add(
          :definition_source, :fdl,
          value: definition_source, message: generator.error
        )
      end
    end
  end

  def update_from_fdl(definition_source)
    generator = Framework::Definition::Generator.new(definition_source, Rails.logger)

    if generator.success?
      update(
        definition_source: definition_source,
        name: generator.definition.framework_name,
        short_name: generator.definition.framework_short_name
      )
      load_lots!
    else
      # Hand over to the validator
      update(definition_source: definition_source)
    end
  end

  def load_lots!
    generator = Framework::Definition::Generator.new(definition_source, Rails.logger)
    fdl_lots = generator.definition.lots || {}

    transaction do
      lots.reject { |lot| fdl_lots.key? lot.number }.each(&:destroy)

      fdl_lots.each_pair do |number, description|
        lot = lots.find_or_initialize_by(number: number)
        lot.description = description
        lot.save!
      end
    end
  end

  def lot_has_suppliers_onboarded?(definition_source)
    generator = Framework::Definition::Generator.new(definition_source, Rails.logger)

    if generator.success?
      fdl_lots = generator.definition.lots || {}
      old_lots = lots.reject { |lot| fdl_lots.key? lot.number }

      old_lots.any?(&:active_agreement?)
    else
      update(definition_source: definition_source)
    end
  end

  def can_be_archived?
    published? && agreements.active.none?
  end
end
