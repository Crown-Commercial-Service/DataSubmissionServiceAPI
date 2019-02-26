require 'framework/definition/AST/creator'

class Framework
  module Definition
    class Language
      class << self
        ##
        # Generate an anonymous outer class with framework metadata
        # and either one or two nested +EntryData+ classes with field definitions
        # and validations for Invoices and Contracts.
        #
        # params
        # +source+ Framework definition language content to parse
        def generate_framework_definition(source, logger = Logger.new(STDERR))
          cst = parse(source, logger)
          ast = Framework::Definition::AST::Creator.new.apply(cst)

          Transpiler.new(ast).transpile
        end

        private

        def parse(source, logger)
          Framework::Definition::Parser.new.parse(source, reporter: Parslet::ErrorReporter::Deepest.new)
        rescue Parslet::ParseFailed => e
          logger.error(e.parse_failure_cause.ascii_tree)
          raise
        end
      end
    end
  end
end
