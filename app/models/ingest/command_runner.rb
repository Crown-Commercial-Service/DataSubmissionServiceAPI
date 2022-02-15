require 'open3'

module Ingest
  ##
  # Run the given +command+ using Open3
  #
  # A +Result+ object is returned, which gives access to
  # +stdout+, +stderr+ and a +successful?+ boolean which
  # is false when the command fails to complete
  class CommandRunner
    Result = Struct.new(:successful?, :stdout, :stderr)

    def initialize(command)
      @command = command
      @stdout = []
      @stderr = []
    end

    def run!
      Rails.logger.info "Running: #{@command.truncate(160)}"

      begin
        Open3.popen3(@command) do |_in, out, err, thread|
          out.each do |line|
            @stdout << line.strip
          end

          err.each do |line|
            @stderr << line.strip
          end

          @status = thread.value
        end
      rescue Errno::ENOENT
        return Result.new(false, @stdout, @stderr)
      end

      Result.new(@status.success?, @stdout, @stderr)
    end
  end
end
