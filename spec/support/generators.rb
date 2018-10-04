require 'rails/generators/test_case'

##
# Generator names should be used in the top-level describe
module GeneratorExampleGroup
  extend ActiveSupport::Concern

  included do
    include Rails::Generators::Testing::Behaviour
    include Rails::Generators::Testing::SetupAndTeardown
    include Rails::Generators::Testing::Assertions
    include FileUtils

    before do
      self.destination_root = destination
      self.generator_class = self.class.top_level_description.constantize
      self.default_arguments = generator_arguments

      prepare_destination
      run_generator
    end
  end
end

RSpec.configure do |config|
  # Tag Generator specs with `:generator` metadata or put them in the spec/lib/generators dir
  config.define_derived_metadata(file_path: %r{/spec/lib/generators}) do |metadata|
    metadata[:type] = :generator
  end

  config.include GeneratorExampleGroup, type: :generator

  config.before(:suite) do
    Rails.application.load_generators
  end
end
