class Admin::UserBulkImportsController < AdminController
  def new; end

  def create
    return redirect_to new_admin_user_bulk_import_path, alert: 'Uploaded file is not a CSV file' unless csv?

    csv_path = uploaded_file.tempfile.path
    Import::Users.new(csv_path, logger: Rails.logger).run

    redirect_to new_admin_user_bulk_import_path, notice: 'Successfully imported users'
  rescue ActionController::ParameterMissing
    redirect_to new_admin_user_bulk_import_path, alert: 'Please choose a file to upload'
  rescue ActiveRecord::RecordNotFound, ArgumentError => e
    redirect_to new_admin_user_bulk_import_path, alert: e.message
  end

  private

  def uploaded_file
    params.require(:bulk_import).require(:csv_file)
  end

  def csv?
    uploaded_file.content_type == 'text/csv'
  end
end
