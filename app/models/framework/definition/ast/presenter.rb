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

        def entry_types
          %i[invoice contract other].select { |fields_type| ast[:"#{fields_type}_fields"] }
        end

        def field_defs(entry_type)
          fields_key = "#{entry_type}_fields".to_sym
          ast[fields_key]
        end

        def lookups
          @lookups ||= ast.fetch(:lookups, {}).tap do |lookups|
            lookups.transform_values! do |list|
              expanded_values = list.map do |item|
                if item.is_a?(LookupReference)
                  ast[:lookups][item]
                else
                  item
                end
              end
              expanded_values.flatten
            end
          end
        end

        def field_by_name(entry_type, name)
          field_def = field_defs(entry_type).find { |f| f[:field] == name } || return

          Field.new(field_def, lookups)
        end

        def field_by_sheet_name(entry_type, name)
          field_def = field_defs(entry_type).find { |f| f[:from] == name } || return

          Field.new(field_def, lookups)
        end
      end
    end
  end
end
