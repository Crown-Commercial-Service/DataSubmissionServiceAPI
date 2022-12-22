class Admin::UserBulkImportsController < AdminController
  def new
    @bulk_user_uploads = BulkUserUpload.order(created_at: :desc).all
  end

  def create
    return redirect_to new_admin_user_bulk_import_path, alert: 'Uploaded file is not a CSV file' unless csv?

    @bulk_user_upload = BulkUserUpload.new(bulk_user_upload_params)

    UserImportJob.perform_later(@bulk_user_upload) if @bulk_user_upload.save

    render action: :new
  rescue ActionController::ParameterMissing
    redirect_to new_admin_user_bulk_import_path, alert: 'Please choose a file to upload'
  end

  private

  def bulk_user_upload_params
    params.require(:bulk_import).permit(:csv_file)
  end

  def csv?
    uploaded_file = params.require(:bulk_import).require(:csv_file)
    File.extname(uploaded_file.original_filename) == '.csv' &&
      ['text/csv', 'application/vnd.ms-excel'].include?(uploaded_file.content_type)
  end
end
