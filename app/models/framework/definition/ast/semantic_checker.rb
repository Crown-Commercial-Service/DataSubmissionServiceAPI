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
          management_field_validations(ast[:management_charge])
          raise_when_field_invalid
        end

        private

        def raise_when_field_invalid
          ast.entry_types.each do |entry_type|
            fields = ast.field_defs(entry_type).map { |field_def| AST::Field.new(field_def, ast.lookups) }
            fields.each do |field|
              raise Transpiler::Error, field.error if field.error

              validate_field_mapping(field, entry_type)
              next unless field.dependent_field_inclusion?

              raise_when_dependent_reference_invalid(field, entry_type)
              raise_when_dependent_reference_has_mismatched_arity(field)
              raise_when_lookup_reference_invalid(field)
            end
          end
        end

        def validate_field_mapping(field, entry_type)
          excluded_headers = %w[CustomerPostCode VATIncluded UNSPSC]

          return if excluded_headers.include?(field.warehouse_name) || field.unknown?

          raise_mapping_error(field, entry_type) unless export_headers_for(entry_type).include? field.warehouse_name
        end

        def export_headers_for(entry_type)
          case entry_type
          when :invoice
            Export::Invoices::HEADER
          when :contract
            Export::Contracts::HEADER
          else
            Export::Others::HEADER
          end
        end

        def raise_mapping_error(field, entry_type)
          raise Transpiler::Error, "#{field.warehouse_name} is not an exported field in the #{entry_type.capitalize}Fields block"
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
          "(#{values.join(', ')})"
        end

        def raise_when_lookup_reference_invalid(field)
          field.dependent_field_lookup_references.each do |lookup_reference|
            valid_lookup_reference = ast.dig(:lookups, lookup_reference)
            next if valid_lookup_reference

            raise Transpiler::Error, "'#{lookup_reference}' is not a valid lookup reference"
          end
        end

        def management_field_validations(info)
          if info[:sector_based]
            raise_when_sector_based_management_field_invalid(info)
          else
            raise_when_management_field_invalid(info)
          end
        end

        def raise_when_sector_based_management_field_invalid(info)
          info[:sector_based].each do |sector, sector_info|
            of_columns_for(sector_info).each { |referenced_field_name| validate_management_field(referenced_field_name) }
            validate_multi_column_management_charge(sector_info) if multi_column_based?(sector_info)
            raise_when_unexpected_number_of_variables(sector_info) if sector_info[:column_names]
          end
        end

        def raise_when_management_field_invalid(info)
          of_columns_for(info).each { |referenced_field_name| validate_management_field(referenced_field_name) }
          validate_multi_column_management_charge(info) if multi_column_based?(info)
          raise_when_unexpected_number_of_variables(info)
        end

        def of_columns_for(info)
          Array(
            if info[:column_based]
              varies_by = Array(info[:column_based][:column_names])

              percentage_columns = info[:column_based][:value_to_percentage]
                                     .values
                                     .select { |percentage_details| percentage_details[:column].present? }
                                     .map    { |percentage_details| percentage_details[:column] }

              varies_by + percentage_columns
            elsif info[:column_names]
              varies_by = Array(info[:column_names])

              percentage_columns = info[:value_to_percentage]
                                     .values
                                     .select { |percentage_details| percentage_details[:column].present? }
                                     .map    { |percentage_details| percentage_details[:column] }

              varies_by + percentage_columns
            elsif info[:flat_rate]
              info.dig(:flat_rate, :column)
            end
          )
        end

        def validate_management_field(referenced_field_name)
          field = ast.field_by_sheet_name(:invoice, referenced_field_name)
          if field.nil?
            raise Transpiler::Error, "Management charge references '#{referenced_field_name}' which does not exist"
          end

          if field.optional?
            raise Transpiler::Error, "Management charge references '#{referenced_field_name}' so it cannot be optional"
          end
        end

        def validate_multi_column_management_charge(info) 
          management_field_keys = info[:value_to_percentage]&.keys || info[:column_based][:value_to_percentage]&.keys
          management_field_keys.each do |key|
            raise_when_incomplete_or_incorrect_keys(key)
            raise_when_first_arg_wildcard(key)
          end
        end

        def raise_when_incomplete_or_incorrect_keys(key)
          unless key.is_a?(Array)
            raise Transpiler::Error, 'This framework definition contains an incorrect or incomplete depends_on rule'
          end
        end

        def raise_when_unexpected_number_of_variables(info)
          return if info[:flat_rate]

          column_names = info[:column_names] || info[:column_based][:column_names]
          management_field_keys = info[:value_to_percentage]&.keys || info[:column_based][:value_to_percentage]&.keys
          
          management_field_keys.each do |key|
            next if key.is_a?(String) && column_names.is_a?(String)

            if key.count != column_names.count
              raise Transpiler::Error, "Unexpected number of variables in #{key}, inside ManagementCharge block."
            end
          end
        end

        def raise_when_first_arg_wildcard(key)
          if key[0] == '<Any>'
            raise Transpiler::Error, 'The first criterion in a multiple depends-on validation cannot be a wildcard.'
          end
        end

        def multi_column_based?(info)
          if info[:column_based]
            Array(info[:column_based][:column_names]).count > 1
          elsif info[:column_names]
            Array(info[:column_names]).count > 1
          end
        end
      end
    end
  end
end
