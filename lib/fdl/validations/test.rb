require 'hashdiff'

module FDL
  module Validations
    class Test
      class Compare
        attr_reader :entry, :framework_short_name
        def initialize(entry, framework_short_name)
          @entry                = entry
          @framework_short_name = framework_short_name
        end

        def original_errors
          invoice = original_invoice_class.new(entry)
          invoice.validate
          invoice.errors.to_h
        end

        def fdl_errors
          invoice = fdl_invoice_class.new(entry)
          invoice.validate
          invoice.errors.to_h
        end

        def diff_s
          return nil if original_errors == fdl_errors

          "#{entry.id} on #{entry.created_at}:\n"\
          "\t#{entry.data.to_h}\n"\
          "\t#{original_errors}\n"\
          "\t#{fdl_errors}\n"\
          "\t#{diff}\n"\
        end

        def diff
          HashDiff.diff(original_errors, fdl_errors)
        end

        private

        def fdl_invoice_class
          @fdl_invoice_class ||= fdl_definition::Invoice
        end

        def fdl_definition
          Framework::Definition::Language[framework_short_name]
        end

        def original_invoice_class
          @original_invoice_class ||= original_definition::Invoice
        end

        def original_definition
          @original_definition ||= Framework::Definition[@framework_short_name]
        end
      end

      attr_reader :framework_short_name, :sample_row_count
      def initialize(framework_short_name, sample_row_count)
        @framework_short_name = framework_short_name
        @sample_row_count     = sample_row_count
      end

      def sample_rows
        SubmissionEntry
          .joins(submission: :framework)
          .where('frameworks.short_name = ?', [framework_short_name])
          .order(created_at: :desc)
          .limit(sample_row_count)
      end

      def run
        diff_count = 0
        sample_rows.each do |entry|
          compare = Compare.new(entry, framework_short_name)
          if compare.diff.any?
            puts compare.diff_s
            diff_count += 1
          end
        end
        puts diff_count
      end
    end
  end
end
