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

      log "Exporting #{model_plural}"
      Tempfile.new([model_plural, '.csv']).tap do |file|
        export_class.new(@relation, file).run
        file.rewind
      end
    end

    private

    def model_classname
      if @relation.klass == SubmissionEntriesStage
        {
          'invoice' => 'Invoice',
          'order'   => 'Contract',
          'other'   => 'Other'
        }.fetch(@relation.where_values_hash['entry_type'])
      elsif @relation.klass == SubmissionEntry
        {
          'invoice' => 'Invoice',
          'order'   => 'Contract',
          'other'   => 'Other'
        }.fetch(@relation.where_values_hash['entry_type'])
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

    def log(message)
      logger.info message
    end
  end
end
