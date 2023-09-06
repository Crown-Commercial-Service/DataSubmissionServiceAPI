class Admin::UserBulkDeactivationController < AdminController
  def new; end

  def create
    return redirect_to new_admin_user_bulk_deactivate_path, alert: 'Uploaded file is not a CSV file' unless csv?

    csv_path = uploaded_file.tempfile.path
    Offboard::DeactivateUsers.new(csv_path, logger: Rails.logger).run

    redirect_to new_admin_user_bulk_deactivate_path, notice: 'Successfully deactivated users'
  rescue ActionController::ParameterMissing
    redirect_to new_admin_user_bulk_deactivate_path, alert: 'Please choose a file to upload'
  rescue ActiveRecord::RecordNotFound, ArgumentError => e
    redirect_to new_admin_user_bulk_deactivate_path, alert: e.message
  end

  private

  def uploaded_file
    params.require(:bulk_deactivate).require(:csv_file)
  end

  def csv?
    File.extname(uploaded_file.original_filename) == '.csv' &&
      ['text/csv', 'application/vnd.ms-excel'].include?(uploaded_file.content_type)
  end
end
