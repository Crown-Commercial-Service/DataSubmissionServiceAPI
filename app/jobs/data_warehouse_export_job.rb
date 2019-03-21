class DataWarehouseExportJob < ApplicationJob
  def perform
    DataWarehouseExport.generate!
  end
end
