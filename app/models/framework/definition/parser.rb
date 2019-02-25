class Framework
  module Definition
    class Parser < Parslet::Parser
      root(:framework)
      rule(:framework) do
        str('Framework') >> space >> framework_identifier.as(:framework_short_name) >> space >> str('{}')
      end

      rule(:framework_identifier) { match(%r{[A-Z0-9/]}).repeat(1).as(:string) }
      rule(:space) { match(/\s/).repeat(1) }
    end
  end
end
