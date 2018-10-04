# Export spec failures truncate their buffer to 14.
# This isn't good on long CSV lines.
# Make it bigger for our export specs.

module ExporterExampleGroup
  extend ActiveSupport::Concern

  included do
    before do
      @_old_formatted_length = RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length
      RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = 400
    end

    after do
      RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = @_old_formatted_length
    end
  end
end

RSpec.configure do |config|
  config.define_derived_metadata(file_path: %r{/spec/lib/tasks/export}) do |metadata|
    metadata[:exporter_spec] = true
  end

  config.include ExporterExampleGroup, exporter_spec: true
end
