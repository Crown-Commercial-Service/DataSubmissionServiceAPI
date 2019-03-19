require 'forwardable'

class Framework
  module Definition
    module AST
      ##
      # A decorator for a plain old +Hash+ containing an AST.
      # Contains a bit of syntactic sugar to make the +Transpiler+
      # look less verbose.
      class Presenter
        extend Forwardable

        attr_accessor :ast
        def_delegators :ast, :[], :dig

        def initialize(ast)
          self.ast = ast
        end

        def field_defs(entry_type)
          fields_key = "#{entry_type}_fields".to_sym
          ast[fields_key]
        end

        def lookups
          ast.fetch(:lookups, {})
        end
      end
    end
  end
end
