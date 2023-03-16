class Admin::UrnListsController < AdminController
  before_action :find_latest_list, only: %i[index download]

  def index
    @urn_lists = UrnList.order(created_at: :desc).all
  end

  def new
    @urn_list = UrnList.new
  end

  def create
    @urn_list = UrnList.new(urn_list_params)

    if @urn_list.save
      UrnListImporterJob.perform_later(@urn_list)

      return redirect_to admin_urn_lists_path
    end

    render action: :new
  end

  def download
    resp = s3_client.get_object(bucket: bucket, key: @latest_urn_list.file_key)
    send_data resp.body.read, filename: @latest_urn_list.file_name.to_s
  end

  private

  def urn_list_params
    params.require(:urn_list).permit(:excel_file)
  end

  def find_latest_list
    @latest_urn_list = UrnList.processed.order(created_at: :desc).first
  end

  def s3_client
    @s3_client ||= Aws::S3::Client.new(region: ENV['AWS_S3_REGION'])
  end

  def bucket
    ENV.fetch('AWS_S3_BUCKET')
  end
end
