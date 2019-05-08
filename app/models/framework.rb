class Framework < ApplicationRecord
  has_many :lots, dependent: :nullify, class_name: 'FrameworkLot'
  has_many :submissions, dependent: :nullify

  has_many :agreements, dependent: :destroy
  has_many :suppliers, through: :agreements

  validates :name, presence: true
  validates :short_name, presence: true, uniqueness: true
  validates :coda_reference, allow_nil: true, format: {
    with: /\A40\d{4}\z/,
    message: 'must start with “40” and have four additional numbers, for example: “401234”'
  }

  validates :definition_source, fdl: true, allow_nil: true

  scope :published, -> { where(published: true) }

  has_one_attached :template_file

  def definition
    @definition ||= Definition[short_name]
  end

  def file_key
    template_file&.attachment&.key
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
end
