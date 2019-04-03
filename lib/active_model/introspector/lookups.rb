require 'active_model/introspector/lookup'

module ActiveModel
  class Introspector
    class Lookups
      include Enumerable

      attr_reader :definition

      def initialize(definition)
        @definition = definition
      end

      def each
        all_caps_arrays.each { |c| yield Lookup.new(c, definition.const_get(c)) }
      end

      private

      ONLY_ALL_CAPS_CONSTS = /^[A-Z0-9_]*$/.freeze

      def all_caps_arrays
        definition.constants.select { |c| c.to_s =~ ONLY_ALL_CAPS_CONSTS && definition.const_get(c).is_a?(Array) }
      end
    end
  end
end
