class DataWarehouseExport < ApplicationRecord
  EARLIEST_RANGE_FROM = Time.new(2000, 1, 1).utc.freeze

  after_initialize :set_date_range

  def self.generate!(reexport: false)
    new(range_from: (EARLIEST_RANGE_FROM if reexport)).tap do |export|
      ActiveRecord::Base.transaction(isolation: :repeatable_read) do
        files = export.generate_files
        Export::AzureUpload.new(files).perform
        export.save!
        export.clear_records_from_staging_table
      end
    end
  end

  def generate_files
    {
      "tasks_#{timestamp}.csv" => tasks_export_file,
      "submissions_#{timestamp}.csv" => submissions_export_file,
      "invoices_#{timestamp}.csv" => invoices_export_file,
      "contracts_#{timestamp}.csv" => contracts_export_file,
      "others_#{timestamp}.csv" => others_export_file,
    }.compact
  end

  def date_range
    (range_from..range_to)
  end

  def clear_records_from_staging_table
    relevant_states = %w[completed validation_failed replaced ingest_failed management_charge_calculation_failed]
    submission_scope = Submission.where(updated_at: date_range, aasm_state: relevant_states)
    SubmissionEntriesStage.joins(:submission).merge(submission_scope).delete_all
  end

  private

  def tasks_export_file
    Export::Relation.new(Export::Tasks::Extract.all_relevant(date_range)).run
  end

  def submissions_export_file
    Export::Relation.new(Export::Submissions::Extract.all_relevant(date_range)).run
  end

  def invoices_export_file
    Export::Relation.new(Export::Invoices::Extract.all_relevant(date_range)).run
  end

  def contracts_export_file
    Export::Relation.new(Export::Contracts::Extract.all_relevant(date_range)).run
  end

  def others_export_file
    Export::Relation.new(Export::Others::Extract.all_relevant(date_range)).run
  end

  def set_date_range
    self.range_from ||= last_export_date || EARLIEST_RANGE_FROM
    self.range_to   ||= Time.zone.now
  end

  def timestamp
    range_to.strftime('%Y%m%d_%H%M%S')
  end

  def last_export_date
    DataWarehouseExport.maximum(:range_to)
  end
end
