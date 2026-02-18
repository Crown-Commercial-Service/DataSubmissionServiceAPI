class DataWarehouseExportJob < ApplicationJob
  def perform
    DataWarehouseExport.generate!
    CleanupSubmissionEntriesJob.perform_later
  end
end
