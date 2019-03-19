module Export
  class Relation
    attr_reader :logger

    def initialize(relation, logger = Rails.logger)
      @relation = relation
      @logger = logger
    end

    def run
      if @relation.empty?
        log "No #{model_plural} to export"
        return
      end

      output_io do |output|
        export_class.new(@relation, output).run
      end
    end

    private

    def model_classname
      if @relation.klass == SubmissionEntry
        if @relation.where_values_hash['entry_type'] == 'invoice'
          'Invoice'
        else
          'Contract'
        end
      else
        @relation.klass.to_s
      end
    end

    def export_class
      "Export::#{model_classname.to_s.pluralize}".constantize
    end

    def model_plural
      model_classname.to_s.downcase.pluralize
    end

    def output_io
      log "Exporting #{model_plural} to #{filename}"
      File.open(filename, 'w+') do |file|
        yield file
      end
    end

    def filename
      "/tmp/#{model_plural}_#{Time.zone.today}.csv"
    end

    def log(message)
      logger.info message
    end
  end
end
