require 'csv'

class Task
  # Used to generate CSV for customer effort scores
  # within a given date range.

  class CustomerEffortScoreList
    HEADER = ['user id', 'rating', 'comments', 'date'].freeze

    attr_reader :logger, :output, :date_from, :date_to

    def initialize(date_from:, date_to:, output: $stdout, logger: Rails.logger)
      @date_from = date_from
      @date_to = date_to
      @output = output
      @logger = logger
    end

    delegate :info, :warn, to: :logger

    def generate
      logger.info "Generating customer effort scores from #{@date_from} to #{@date_to}"

      output.puts(CSV.generate_line(HEADER))

      customer_effort_scores.each do |score|
        output.puts csv_line_for(score)
      end
    end

    def csv_line_for(score)
      CSV.generate_line(
        [score.user_id, score.rating, score.comments, score.created_at]
      )
    end

    private

    def customer_effort_scores
      CustomerEffortScore.where(created_at: date_from..date_to)
    end
  end
end
