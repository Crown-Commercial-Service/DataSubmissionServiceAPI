class Framework
  module Definition
    class Language
      def self.generate_framework_definition(source)
        Class.new(Framework::Definition::Base)
      end
    end
  end
end
