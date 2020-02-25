class Framework
  module Definition
    module AST
      ##
      # Given an AST::Presenter as @ast,
      # throw the first semantic error we find via Transpiler::Error.
      #
      # Any error that isn't syntactic in nature is semantic. Things like:
      #   - referencing a management charge field that doesn't exist
      #   - referencing a management charge field that's erroneously optional
      #   - referencing a dependent field that doesn't exist
      #
      # One method per type of check in #run
      class SemanticChecker
        attr_reader :ast

        def initialize(ast)
          @ast = ast
        end

        def run
          raise_when_management_field_invalid(ast[:management_charge])
          raise_when_field_invalid
        end

        private

        def raise_when_field_invalid
          ast.entry_types.each do |entry_type|
            fields = ast.field_defs(entry_type).map { |field_def| AST::Field.new(field_def, ast.lookups) }
            fields.each do |field|
              raise Transpiler::Error, field.error if field.error
              next unless field.dependent_field_inclusion?

              raise_when_dependent_reference_invalid(field, entry_type)
              raise_when_dependent_reference_has_mismatched_arity(field)
              raise_when_lookup_reference_invalid(field)
            end
          end
        end

        def raise_when_dependent_reference_invalid(field, entry_type)
          field.dependent_fields.each do |dependent_field|
            valid_reference = ast.field_defs(entry_type).find { |f| f[:from] == dependent_field }
            next if valid_reference

            raise Transpiler::Error,
                  "'#{field.sheet_name}' depends on '#{dependent_field}', which does not exist"
          end
        end

        def raise_when_dependent_reference_has_mismatched_arity(field)
          num_dependent_fields = field.dependent_fields.size

          field.dependent_field_inclusion_values.each_key do |key|
            next if key.size == num_dependent_fields

            raise Transpiler::Error,
                  "'#{field.sheet_name}' depends on #{num_dependent_fields} fields " \
                  "#{format_list(field.dependent_fields)} but contains a match on " \
                  "#{key.size} values #{format_list(key)}"
          end
        end

        def format_list(array)
          values = array.map { |value| value.is_a?(String) ? "'#{value}'" : value }
          '(' + values.join(', ') + ')'
        end

        def raise_when_lookup_reference_invalid(field)
          field.dependent_field_lookup_references.each do |lookup_reference|
            valid_lookup_reference = ast.dig(:lookups, lookup_reference)
            next if valid_lookup_reference

            raise Transpiler::Error, "'#{lookup_reference}' is not a valid lookup reference"
          end
        end

        def raise_when_management_field_invalid(info)
          of_columns_for(info).each { |referenced_field_name| validate_management_field(referenced_field_name) }
        end

        def of_columns_for(info)
          Array(
            if info[:column_based]
              varies_by = Array(info[:column_based][:column_names])

              percentage_columns = info[:column_based][:value_to_percentage]
                                     .values
                                     .select { |percentage_details| percentage_details[:column].present? }
                                     .map    { |percentage_details| percentage_details[:column] }

              varies_by.concat percentage_columns
            elsif info[:flat_rate]
              info.dig(:flat_rate, :column)
            end
          )
        end

        def validate_management_field(referenced_field_name)
          field = ast.field_by_sheet_name(:invoice, referenced_field_name)
          raise Transpiler::Error, "Management charge references '#{referenced_field_name}' which does not exist" if field.nil?
          raise Transpiler::Error, "Management charge references '#{referenced_field_name}' so it cannot be optional" if field.optional?
        end
      end
    end
  end
end
