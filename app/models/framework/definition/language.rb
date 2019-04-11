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

        def [](framework_short_name)
          sanitized_short_name = framework_short_name.tr('/.', '_')

          fdl_filename = Rails.root.join("app/models/framework/definition/#{sanitized_short_name}.fdl")

          raise ArgumentError, "#{framework_short_name}.fdl does not exist in models/framework/definition" \
            unless File.exist?(fdl_filename)

          generate_framework_definition(File.read(fdl_filename))
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
