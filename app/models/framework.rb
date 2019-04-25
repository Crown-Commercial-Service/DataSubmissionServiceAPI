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

  def definition
    @definition ||= Definition[short_name]
  end

  def self.new_from_fdl(definition_source)
    Framework.new(definition_source: definition_source).tap do |framework|
      definition = Framework::Definition::Language.generate_framework_definition(definition_source, Rails.logger)
      framework.name       = definition.framework_name
      framework.short_name = definition.framework_short_name
    rescue Parslet::ParseFailed => e
      framework.errors.add(
        :definition_source, :fdl,
        value: definition_source, message: e.parse_failure_cause.ascii_tree
      )
    end
  end

  def update_from_fdl(definition_source)
    definition = begin
                   Framework::Definition::Language.generate_framework_definition(definition_source, Rails.logger)
                 rescue Parslet::ParseFailed
                   return update(definition_source: definition_source)
                 end

    update(
      definition_source: definition_source,
      name: definition.framework_name,
      short_name: definition.framework_short_name
    )
  end
end
