class Framework
  module Definition
    class Parser < Parslet::Parser
      root(:framework)
      rule(:framework) do
        str('Framework') >>
          spaced(framework_identifier.as(:framework_short_name)) >>
          spaced(framework_block)
      end

      rule(:pascal_case_identifier) { (match(/[A-Z]/) >> match(/[a-z0-9]/).repeat).repeat(1) }
      rule(:additional_field_identifier) { str('Additional') >> match('[0-9]').repeat(1) }

      rule(:framework_identifier) { match(%r{[A-Z0-9/]}).repeat(1).as(:string) }
      rule(:framework_block)      { braced(spaced(metadata) >> spaced(invoice_fields)) }
      rule(:framework_name)       { str('Name') >> spaced(string.as(:framework_name)) }
      rule(:management_charge)    { str('ManagementCharge') >> spaced(percentage).as(:management_charge) }
      rule(:invoice_fields)       { str('InvoiceFields') >> spaced(fields_block.as(:invoice_fields)) }
      rule(:fields_block)         { braced(spaced(field_defs)) }

      rule(:field_defs)           { field_def.repeat(1) }
      rule(:field_def)            { unknown_field | known_field | additional_field }
      rule(:known_field)          { pascal_case_identifier.as(:field) >> from_specifier }
      rule(:additional_field)     { str('String').as(:type) >> space >> additional_field_identifier.as(:field) >> from_specifier }
      rule(:unknown_field)        { str('String').as(:type) >> space >> from_specifier }

      rule(:percentage)           { (decimal | integer).as(:flat_rate) >> str('%') >> space? }
      rule(:from_specifier)       { spaced(str('from')) >> string.as(:from) }

      rule(:metadata)             { framework_name >> management_charge }

      rule(:string) do
        str("'") >> (
          str("'").absent? >> any
        ).repeat.as(:string) >> str("'") >> space?
      end
      rule(:integer) { match(/[0-9]/).repeat >> space? }
      rule(:decimal) { (integer >> (str('.') >> match('[0-9]').repeat(1))).as(:decimal) >> space? }

      rule(:space)   { match(/\s/).repeat(1) }
      rule(:space?)  { space.maybe }

      rule(:lbrace)  { str('{') >> space? }
      rule(:rbrace)  { str('}') >> space? }

      ##
      # It is often the case that we need spaces before and after
      # an atom.
      def spaced(atom)
        space? >> atom >> space?
      end

      ##
      # braced(atom1 >> atom 2) reads better than
      # lbrace >> atom 1 >> atom2 >> brace in most situations.
      def braced(atom)
        lbrace >> atom >> rbrace
      end
    end
  end
end
