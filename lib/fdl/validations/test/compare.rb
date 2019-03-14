require 'hashdiff'

module FDL
  module Validations
    class Test
      ##
      # Given a +entry+ and a +framework+, allow us to compute the +diff+ of
      # validation errors, if any exist.
      class Compare
        attr_reader :entry, :framework_short_name, :fdl_definition
        def initialize(entry, framework_short_name, fdl_definition)
          @entry                = entry
          @framework_short_name = framework_short_name
          @fdl_definition       = fdl_definition
        end

        def original_invoice
          @original_invoice ||= original_invoice_class.new(entry)
        end

        def original_errors
          original_invoice.validate
          original_invoice.errors.to_h
        end

        def fdl_invoice
          @fdl_invoice ||= fdl_invoice_class.new(entry)
        end

        def fdl_errors
          invoice = fdl_invoice
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

        def fdl_invoice_class
          @fdl_invoice_class ||= fdl_definition::Invoice
        end

        def original_invoice_class
          @original_invoice_class ||= original_definition::Invoice
        end

        def original_definition
          @original_definition ||= Framework::Definition[@framework_short_name]
        end
      end
    end
  end
end
