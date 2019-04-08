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

        def original_entry
          @original_entry ||= original_entry_class.new(entry)
        end

        def original_errors
          original_entry.validate
          original_entry.errors.to_hash.transform_values(&:sort)
        end

        def fdl_entry
          @fdl_entry ||= fdl_entry_class.new(entry)
        end

        def fdl_errors
          entry = fdl_entry
          entry.validate
          entry.errors.to_hash.transform_values(&:sort)
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

        def fdl_entry_class
          @fdl_entry_class ||= entry_class(fdl_definition)
        end

        def original_entry_class
          @original_entry_class ||= entry_class(original_definition)
        end

        def original_definition
          @original_definition ||= Framework::Definition[@framework_short_name]
        end

        private

        def entry_class(definition)
          case entry.entry_type
          when 'invoice' then definition::Invoice
          when 'order'   then definition::Order
          else
            raise 'entry.entry_type neither invoice nor order'
          end
        end
      end
    end
  end
end
