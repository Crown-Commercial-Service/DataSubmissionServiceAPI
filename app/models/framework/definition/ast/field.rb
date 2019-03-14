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

        attr_reader :field_def
        def initialize(field_def)
          @field_def = field_def
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
        # 'Our' type; things like :string, :yesno, :decimal
        def primitive_type
          case kind
          when :known
            DataWarehouse::KnownFields.type_for(warehouse_name)
          else
            PRIMITIVE_TYPES[field_def[:type]] || :string
          end
        end

        def lookup?
          field_def[:type] && PRIMITIVE_TYPES[field_def[:type]].nil?
        end

        def lookup_name
          field_def[:type] if lookup?
        end

        ##
        # The implementation type. Usually :string
        def activemodel_type
          %i[integer urn].include?(primitive_type) ? :integer : :string
        end

        def validators?
          PRIMITIVE_TYPE_VALIDATIONS.fetch(primitive_type).any?
        end

        def options(lookup_values)
          Field::Options.new(self).build(lookup_values)
        end

        def self.by_name(field_defs, name)
          Field.new(field_defs.find { |f| f[:field] == name })
        end
      end
    end
  end
end
