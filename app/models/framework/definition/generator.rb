class Framework
  module Definition
    ##
    # Given FDL source, generate an anonymous class that is a framework's definition.
    #
    # +definition+ holds the finished class if generation was successful.
    # If +definition+ is nil, +error+ holds either:
    #   - a parse tree, or
    #   - the first semantic error that the +Transpiler+ encountered.
    #
    # There are also +success?+ and +error?+ helper methods which
    # implicitly attempt to create +definition+.
    class Generator
      attr_reader :source, :logger, :error

      def initialize(source, logger = Logger.new($stderr))
        @source = source
        @logger = logger
      end

      def error?
        definition.nil?
      end

      def success?
        !!definition
      end

      def definition
        @definition ||= begin
          cst = parse(source, logger) || return
          ast = Framework::Definition::AST::Creator.new.apply(cst)

          Framework::Definition::Transpiler.new(ast).transpile
        rescue Transpiler::Error => e
          @error = e.message
          nil
        end
      end

      private

      def parse(source, logger)
        Framework::Definition::Parser.new.parse(source, reporter: Parslet::ErrorReporter::Deepest.new)
      rescue Parslet::ParseFailed => e
        @error = e.parse_failure_cause.ascii_tree
        logger.error(@error)
        false
      end
    end
  end
end
