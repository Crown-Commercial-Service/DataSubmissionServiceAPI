module ActiveModel
  class Introspector
    class Lookup
      attr_reader :constant, :values

      def initialize(constant, values)
        @constant = constant
        @values = values
      end

      def fdl_name
        constant.to_s.underscore.classify.sub(/Value$/, '')
      end
    end
  end
end
