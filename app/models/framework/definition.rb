class Framework
  ##
  # Metadata for a framework definition expressed largely as
  # class methods
  class Definition
    class << self
      ##
      # E.g. "Rail Legal Services"
      def framework_name(value = nil)
        @framework_name ||= value
      end

      ##
      # E.g. "RM3786"
      def framework_short_name(value = nil)
        @framework_short_name ||= value
      end
    end
  end
end
