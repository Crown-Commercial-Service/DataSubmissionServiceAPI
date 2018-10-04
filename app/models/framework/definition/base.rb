class Framework
  module Definition
    ##
    # Base class for a framework definition with metadata methods
    class Base
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
end
