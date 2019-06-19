require 'forwardable'

class Framework
  module Definition
    module AST
      ##
      # Take a field_def (which is a small hash) from the AST and put
      # some helper methods# on it to make the +Transpiler+ readable
      class Field
        PRIMITIVE_TYPE_VALIDATIONS = {
          string:     {},
          decimal:    { ingested_numericality: true },
          integer:    { ingested_numericality: { only_integer: true } },
          urn:        { urn: true },
          lot_number: { lot_in_agreement: true },
          date:       { ingested_date: true },
          yesno:      { case_insensitive_inclusion: { in: %w[Y N], message: "must be 'Y' or 'N'" } }
        }.freeze

        PRIMITIVE_TYPES = {
          'Integer' => :integer,
          'String' => :string,
          'Decimal' => :decimal,
          'Date' => :date,
          'YesNo' => :yesno
        }.freeze

        extend Forwardable

        def_delegators :field_def, :[]

        attr_reader :field_def, :lookups
        def initialize(field_def, lookups = {})
          @field_def = field_def
          @lookups = lookups
        end

        def error
          if known? && DataWarehouse::KnownFields::ALL[warehouse_name].nil?
            "known field not found: '#{warehouse_name}'"
          elsif additional? && lookups[lookup_name].nil? && PRIMITIVE_TYPES[source_type].nil?
            "unknown type '#{lookup_name}' (neither primitive nor lookup) for #{warehouse_name}"
          end
        end

        def sheet_name
          field_def[:from]
        end

        def warehouse_name
          field_def[:field]
        end

        def kind
          field_def[:kind]
        end

        def known?
          kind == :known
        end

        def additional?
          kind == :additional
        end

        def unknown?
          kind == :unknown
        end

        def optional?
          field_def[:optional]
        end

        ##
        # The source type; the literal string of the type. e.g.
        # String, Date, SomeLookupName
        def source_type
          field_def.dig(:type, :primitive) || field_def.dig(:type, :lookup)
        end

        ##
        # 'Our' type; things like :string, :yesno, :decimal
        def primitive_type
          case kind
          when :known
            DataWarehouse::KnownFields.type_for(warehouse_name)
          else
            PRIMITIVE_TYPES[source_type] || :string
          end
        end

        def lookup?
          if known?
            lookups.key?(warehouse_name)
          else
            source_type && PRIMITIVE_TYPES[source_type].nil?
          end
        end

        def lookup_name
          return nil unless lookup?

          known? ? warehouse_name : source_type
        end

        ##
        # The implementation type. Usually :string
        def activemodel_type
          %i[urn].include?(primitive_type) ? :integer : :string
        end

        def validators?
          PRIMITIVE_TYPE_VALIDATIONS.fetch(primitive_type).any?
        end

        def options(lookup_values)
          Field::Options.new(self).build(lookup_values)
        end

        def dependent_field_inclusion?
          field_def[:depends_on].present?
        end

        def dependent_field
          field_def[:depends_on][:dependent_field]
        end

        def dependent_field_inclusion_values
          field_def[:depends_on][:values].each_with_object({}) do |(field_value, lookup_name), result|
            result[field_value.downcase] = lookups[lookup_name]
          end
        end

        def length_options
          range = field_def.dig(:type, :range)

          return {} if range.nil?

          if range[:min] && range[:max]
            { in: range[:min]..range[:max] }
          elsif range[:min]
            { minimum: range[:min] }
          elsif range[:max]
            { maximum: range[:max] }
          elsif range[:is]
            { is: range[:is] }
          end
        end
      end
    end
  end
end
