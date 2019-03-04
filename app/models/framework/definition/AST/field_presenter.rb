require 'forwardable'

class Framework
  module Definition
    module AST
      ##
      # Take a field_def from the AST and put some helper methods
      # on it to make the +Transpiler+ readable
      class FieldPresenter
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

        def known?
          field_def[:type].nil?
        end

        def optional?
          field_def[:optional]
        end

        ##
        # 'Our' type; things like :string, :yesno, :decimal
        def type
          field_def[:type].downcase.to_sym
        end

        ##
        # The implementation type. Usually :string
        def activemodel_type
          :string
        end

        def validators?
          field_type = if known?
                         DataWarehouse::KnownFields[warehouse_name]
                       else
                         type
                       end
          Transpiler::TYPE_VALIDATIONS.fetch(field_type).any?
        end

        def self.by_name(field_defs, name)
          FieldPresenter.new(field_defs.find { |f| f[:field] == name })
        end
      end
    end
  end
end
