class Admin::SupplierBulkOffboardsController < AdminController
  def new; end

  def create
    return redirect_to new_admin_supplier_bulk_offboard_path, alert: 'Uploaded file is not a CSV file' unless csv?

    csv_path = uploaded_file.tempfile.path
    Offboard::FrameworkSuppliers.new(csv_path, logger: Rails.logger).run

    redirect_to new_admin_supplier_bulk_offboard_path, notice: 'Successfully off-boarded suppliers'
  rescue ActionController::ParameterMissing
    redirect_to new_admin_supplier_bulk_offboard_path, alert: 'Please choose a file to upload'
  rescue ActiveRecord::RecordNotFound, ArgumentError, ActiveRecord::RecordInvalid => e
    redirect_to new_admin_supplier_bulk_offboard_path, alert: e.message
  end

  private

  def uploaded_file
    params.require(:bulk_offboard).require(:csv_file)
  end

  def csv?
    File.extname(uploaded_file.original_filename) == '.csv' &&
      ['text/csv', 'application/vnd.ms-excel'].include?(uploaded_file.content_type)
  end
end
