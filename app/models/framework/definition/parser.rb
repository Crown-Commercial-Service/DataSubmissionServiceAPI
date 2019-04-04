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

      rule(:framework_identifier) { match(%r{[A-Za-z0-9/]}).repeat(1).as(:string) }
      rule(:framework_block) do
        braced(
          spaced(metadata) >>
          spaced(fields_blocks) >>
          spaced(lookups_block.as(:lookups)).maybe >>
          spaced(lots_block).maybe
        )
      end
      rule(:framework_name)       { str('Name') >> spaced(string.as(:framework_name)) }
      rule(:management_charge)    { str('ManagementCharge') >> (column_based | flat_rate | sector_based).as(:management_charge) }
      rule(:flat_rate)            { (spaced(percentage).as(:value) >> flat_rate_column.maybe).as(:flat_rate) }
      rule(:flat_rate_column)     { spaced(str('of')) >> string.as(:column) }
      rule(:column_based)         { spaced(str('varies_by')) >> (spaced(string).as(:column_name) >> spaced(dictionary).as(:value_to_percentage)).as(:column_based) }
      rule(:sector_based)         { spaced(str('sector_based')) >> spaced(dictionary).as(:sector_based) }
      rule(:invoice_fields)       { str('InvoiceFields') >> spaced(fields_block.as(:invoice_fields)) }
      rule(:contract_fields)      { str('ContractFields') >> spaced(fields_block.as(:contract_fields)) }
      rule(:fields_blocks)        { (invoice_fields >> contract_fields.maybe) | (contract_fields >> invoice_fields.maybe) }
      rule(:fields_block)         { braced(spaced(field_defs)) }

      rule(:field_defs)           { field_def.repeat(1) }
      rule(:field_def)            { unknown_field | known_field | additional_field }
      rule(:known_field)          { optional >> additional_field_identifier.absent? >> pascal_case_identifier.as(:field) >> from_specifier >> depends_on.maybe }
      rule(:additional_field)     { optional >> type_def >> space >> additional_field_identifier.as(:field) >> from_specifier }
      rule(:unknown_field)        { optional >> primitive_type_def.as(:type_def) >> space >> from_specifier }
      rule(:type_def)             { (primitive_type_def | pascal_case_identifier.as(:lookup)).as(:type_def) }
      rule(:primitive_type_def)   { string_def | (str('Date') | str('Integer') | str('Decimal') | str('YesNo')).as(:primitive) }
      rule(:string_def)           { str('String').as(:primitive) >> parenthesised(range).maybe }
      rule(:from_specifier)       { spaced(str('from')) >> string.as(:from) }
      rule(:optional)             { spaced(str('optional').as(:optional).maybe) }

      rule(:lookups_block)        { str('Lookups') >> space >> braced(lookup_key_values.repeat(1)).as(:lookups) }
      rule(:lookup_key_values)    { pascal_case_identifier.as(:lookup_name) >> space >> lookup_item_array }
      rule(:lookup_item_array)    { square_bracketed(lookup_item.repeat(1).as(:list)) }
      rule(:lookup_item)          { (string | lookup_reference) >> space? }
      rule(:lookup_reference)     { pascal_case_identifier.as(:lookup_reference) }

      rule(:lots_block)           { str('Lots') >> space >> dictionary.as(:lots) }

      rule(:depends_on)           { (spaced(str('depends_on')) >> spaced(string).as(:dependent_field) >> dictionary.as(:values)).as(:depends_on) }

      rule(:metadata)             { framework_name >> management_charge }

      rule(:map)                  { allowable_key.as(:key) >> spaced(str('->')) >> allowable_value.as(:value) >> space? }
      rule(:allowable_key)        { string | pascal_case_identifier }
      rule(:allowable_value)      { percentage | lookup_reference | string }
      rule(:dictionary)           { braced(map.repeat(1).as(:dictionary)) }

      rule(:string) do
        str("'") >> (
          str("'").absent? >> any
        ).repeat.as(:string) >> str("'") >> space?
      end

      rule(:integer)    { match(/[0-9]/).repeat.as(:integer) }
      rule(:decimal)    { (match(/[0-9]/).repeat >> (str('.') >> match(/[0-9]/).repeat >> space?)).as(:decimal) }
      rule(:percentage) { (decimal | integer) >> str('%') }
      rule(:range)      { (range_exp | integer.as(:is)).as(:range) }
      rule(:range_exp)  { integer.as(:min).maybe >> str('..') >> integer.as(:max).maybe }

      rule(:space)   { match(/\s/).repeat(1) }
      rule(:space?)  { space.maybe }

      rule(:lbrace)  { str('{') >> space? }
      rule(:rbrace)  { str('}') >> space? }
      rule(:lparen)  { str('(') }
      rule(:rparen)  { str(')') }
      rule(:lsquare) { str('[') >> space? }
      rule(:rsquare) { str(']') >> space? }

      ##
      # It is often the case that we need spaces before and after
      # an atom.
      def spaced(atom)
        space? >> atom >> space?
      end

      ##
      # braced(atom1 >> atom 2) reads better than
      # lbrace >> atom 1 >> atom2 >> rbrace in most situations.
      def braced(atom)
        lbrace >> atom >> rbrace
      end

      ##
      # square_bracketed(atom1 >> atom 2) reads better than
      # lsquare >> atom 1 >> atom2 >> rsquare in most situations.
      def square_bracketed(atom)
        lsquare >> atom >> rsquare
      end

      ##
      # parenthesised(atom1 >> atom 2) reads better than
      # lparen >> atom 1 >> atom2 >> rparen in most situations.
      def parenthesised(atom)
        lparen >> atom >> rparen
      end
    end
  end
end
