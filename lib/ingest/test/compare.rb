require 'hashdiff'

module Ingest
  class Test
    ##
    # Given a +new_entry+ and a +file+ object, find the matching
    # +original_entry+ and return any difference between them
    class Compare
      attr_reader :new_entry, :file

      def initialize(new_entry, file)
        @new_entry = new_entry
        @file = file
      end

      def new_attributes
        new_entry.attributes.except(*EXCLUDED_ATTRIBUTES)
      end

      def original_entry
        file.entries.find_by(source: new_entry.source)
      end

      def original_attributes
        original_entry.attributes.except(*EXCLUDED_ATTRIBUTES)
      end

      # rubocop:disable Metrics/AbcSize
      def diff
        return if original_entry.nil?

        diffs = HashDiff.diff(original_attributes, new_attributes)
        return nil if diffs.blank?

        width1 = diffs.map { |diff| diff[1].to_s.length }.max
        width2 = diffs.map { |diff| diff[2].to_s.length }.max
        width3 = diffs.map { |diff| diff[3].to_s.length }.max

        response = diffs.map do |diff|
          "#{diff[0]}#{diff[1].to_s.ljust(width1, ' ')}|"\
            "#{diff[2].to_s.ljust(width2)}|#{diff[3].to_s.ljust(width3)}|"
        end

        { original_entry.id => response }
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
