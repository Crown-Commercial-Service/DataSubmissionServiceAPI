# https://github.com/jsonapi-rb/jsonapi-rspec/issues/4
#
# jsonapi-rspec replaces RSpec's BuiltIn have_attributes matcher, which
# is useful in language_spec.rb for validating the use of validators via
# +an_object_having_attributes+. While jsonapi-rspec is extremely naughty
# and a bit self-important here, without patching that gem our options are
# limited, because we're using its patched +have_attributes+ in many
# API-related specs.
#
# Since we only use +an_object_having_attributes+, and that isn't in use
# in the API specs replace that here. And consider either dropping or
# patching jsonapi-rspec, which is at the time of writing 2 years without
# a commit.

module RSpec
  module Matchers
    module ReplaceBuiltIn
      extend RSpec::Matchers::DSL

      def an_object_having_attributes(expected)
        BuiltIn::HaveAttributes.new(expected)
      end
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::Matchers::ReplaceBuiltIn
end
