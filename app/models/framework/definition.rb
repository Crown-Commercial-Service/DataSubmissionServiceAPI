class Framework
  module Definition
    class MissingError < StandardError; end

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

    # Require all the framework definitions up-front
    Dir['app/models/framework/definition/*'].each do |definition|
      # `Dir` needs an app-relative path argument, but `require` needs one relative to
      # the $LOAD_PATH. Remove app/models/ to e.g. only `require 'framework/definition/RM1234'`
      relative_definition = Pathname(definition).sub('app/models/', '').sub_ext('').to_s
      require relative_definition
    end
  end
end
