require 'framework/definition/AST/creator'

class Framework
  module Definition
    class Language
      def self.generate_framework_definition(source)
        cst = Framework::Definition::Parser.new.parse(source)
        ast = Framework::Definition::AST::Creator.new.apply(cst)

        Class.new(Framework::Definition::Base) do
          framework_short_name ast.fetch(:framework_short_name)
          framework_name ast.fetch(:framework_name)
        end
      end
    end
  end
end
