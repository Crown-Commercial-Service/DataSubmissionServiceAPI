require 'framework/definition/AST/creator'

class Framework
  module Definition
    class Language
      def self.generate_framework_definition(source)
        cst = Framework::Definition::Parser.new.parse(source)
        ast = Framework::Definition::AST::Creator.new.apply(cst)

        Transpiler.new(ast).transpile
      end
    end
  end
end
