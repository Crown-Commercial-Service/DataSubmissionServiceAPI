require 'progress_bar'
require 'stringio'
require 'ingest/test/compare'

module Ingest
  ##
  # Given an optional +submission_file_id+ test ingest against the stored
  # submission entries to verify its working similarly to the existing
  # process
  #
  # Example usage:
  #
  #   test = Ingest::Validations::Test.new(submission_file_id)
  #   test.run
  #
  # Running without passing parameters will test against 25 randomly
  # selected +submission_files+
  class Test
    attr_reader :sample_count, :submission_file_ids

    EXCLUDED_ATTRIBUTES = [
      'id',
      'created_at',
      'updated_at',
      'validation_errors',
      'management_charge'
    ].freeze

    def initialize(submission_file_ids = nil)
      @submission_file_ids = Array(submission_file_ids)
      @sample_count        = 25

      @discrepancies       = {}
    end

    # rubocop:disable Metrics/AbcSize
    def run
      bar = ProgressBar.new(samples.count)

      samples.find_each do |file|
        bar.increment!

        next unless file.file.attached?
        next if file.rows != file.entries.count

        download = Ingest::SubmissionFileDownloader.new(file).perform
        converter = Ingest::Converter.new(download)
        loader = Ingest::Loader.new(converter, file, false) # Don't persist
        loader.perform

        invoice_discrepancies = compare_entries_from("/tmp/ingest_#{file.id}_invoice.yml", file)
        order_discrepancies   = compare_entries_from("/tmp/ingest_#{file.id}_order.yml", file)

        @discrepancies[file.id] = invoice_discrepancies.merge(order_discrepancies)
      end
    end
    # rubocop:enable Metrics/AbcSize

    def formatted_report
      output = StringIO.new

      @discrepancies.each_pair do |file_id, entries|
        next if entries.count.zero?

        output.puts "File ##{file_id} has #{entries.count} discrepancies"

        entries.each_pair do |entry_id, diffs|
          output.puts "\tEntry ##{entry_id}"

          diffs.each do |diff|
            output.puts "\t\t#{diff}"
          end

          output.puts
        end
      end

      output.string
    end

    private

    def compare_entries_from(yml_file_path, file)
      return {} unless File.exist?(yml_file_path)

      file_discrepancies = []

      # rubocop:disable Security/YAMLLoad
      #
      # Rubocop recommends using YAML.safe_load, but the YAML file
      # references private ActiveModel classes which causes this to fail!
      entries = YAML.load(File.read(yml_file_path))
      # rubocop:enable Security/YAMLLoad

      entries.each do |new_entry|
        compare = Compare.new(new_entry, file)
        diff = compare.diff
        file_discrepancies << diff if diff.present?
      end

      file_discrepancies.map(&:flatten).to_h
    end

    def samples
      @samples ||= if submission_file_ids&.any?
                     by_submission_file_ids
                   else
                     limited_by_number
                   end
    end

    def by_submission_file_ids
      SubmissionFile.where(id: submission_file_ids)
    end

    def limited_by_number
      SubmissionFile
        .order('RANDOM()')
        .where('created_at > ?', 2.months.ago)
        .limit(sample_count)
    end
  end
end
