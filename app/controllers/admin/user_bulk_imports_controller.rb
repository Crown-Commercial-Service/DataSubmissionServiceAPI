class Admin::UserBulkImportsController < AdminController
  def new; end

  def create
    return redirect_to new_admin_user_bulk_import_path, alert: 'Uploaded file is not a CSV file' unless csv?

    csv_path = uploaded_file.tempfile.path
    csv_key = UploadUserList.new(csv_path).call

    UserImportJob.perform_later(csv_key)

    redirect_to new_admin_user_bulk_import_path, notice: 'User import started; this job will run in the background'
  rescue ActionController::ParameterMissing
    redirect_to new_admin_user_bulk_import_path, alert: 'Please choose a file to upload'
  rescue Aws::S3::Errors::ServiceError
    redirect_to new_admin_user_bulk_import_path, alert: 'There was a problem uploading the file'
  end

  private

  def uploaded_file
    params.require(:bulk_import).require(:csv_file)
  end

  def csv?
    File.extname(uploaded_file.original_filename) == '.csv' &&
      ['text/csv', 'application/vnd.ms-excel'].include?(uploaded_file.content_type)
  end
end
