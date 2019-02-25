class Framework
  module Definition
    class Parser < Parslet::Parser
      root(:framework)
      rule(:framework) do
        str('Framework') >>
          spaced(framework_identifier.as(:framework_short_name)) >>
          spaced(framework_block)
      end

      rule(:framework_identifier) { match(%r{[A-Z0-9/]}).repeat(1).as(:string) }
      rule(:framework_block)      { str('{') >> spaced(framework_name) >> str('}') }
      rule(:framework_name)       { str('Name') >> spaced(string.as(:framework_name)) }

      rule(:string) do
        str("'") >> (
          str("'").absent? >> any
        ).repeat.as(:string) >> str("'")
      end

      rule(:space)  { match(/\s/).repeat(1) }
      rule(:space?) { space.maybe }

      ##
      # It is often the case that we need spaces before and after
      # an atom.
      def spaced(atom)
        space? >> atom >> space?
      end
    end
  end
end
