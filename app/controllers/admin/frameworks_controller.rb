class Admin::FrameworksController < AdminController
  # rubocop:disable Layout/LineLength
  before_action :find_framework,
                only: %i[show edit update update_fdl publish download_template archive_confirmation archive unarchive_confirmation
                         unarchive]
  before_action :prevent_republish, only: :publish
  # rubocop:enable Layout/LineLength

  def index
    @frameworks = Framework.order(:short_name).all

    @frameworks = filter_framework_status(@frameworks)
  end

  def new
    @framework = Framework.new
  end

  def show
    fdl_file = Rails.root.join('app', 'models', 'framework', 'definition', "#{@framework.short_name.tr('/.', '_')}.fdl")

    @definition_source = if @framework.definition_source.present?
                           @framework.definition_source
                         elsif File.exist?(fdl_file)
                           File.read(fdl_file)
                         end
  end

  def create
    @framework = Framework.new_from_fdl(framework_params[:definition_source])

    if @framework.errors[:definition_source].any?
      render action: :new
      return
    end

    if @framework.save
      flash[:success] = 'Definition saved successfully'
      redirect_to admin_framework_path(@framework)
    else
      flash[:failure] = 'Could not save definition'
      render action: :new
    end
  end

  def edit; end

  def update
    if params.dig(:framework, :template_file).present?
      return redirect_to admin_framework_path, alert: 'Uploaded file must be a .XLS or .XLSX file.' unless excel_file?

      @framework.update!(framework_params)
      flash[:success] = 'Framework saved successfully.'
    else
      flash[:failure] = I18n.t('errors.message.missing_template_file')
    end

    redirect_to admin_framework_path(@framework)
  end

  def update_fdl
    if @framework.published? && @framework.lot_has_suppliers_onboarded?(framework_params[:definition_source])
      flash[:failure] = 'Please ensure all suppliers are offboarded from Lots that are to be deleted.'
      return redirect_to admin_framework_path(@framework)
    end

    if @framework.update_from_fdl(framework_params[:definition_source])
      flash[:success] = 'Framework saved successfully.'
      redirect_to admin_framework_path(@framework)
    else
      render action: :edit
    end
  end

  def publish
    @framework.publish!
    flash[:success] = 'Framework published successfully.'
    redirect_to admin_framework_path(@framework)
  end

  def archive_confirmation; end

  def archive
    if @framework.can_be_archived?
      @framework.archive!
      flash[:success] = 'Framework archived successfully.'
    else
      flash[:failure] = 'Framework cannot be archived. Ensure it is published and has no active agreements.'
    end
    redirect_to admin_framework_path(@framework)
  end

  def unarchive_confirmation; end

  def unarchive
    if @framework.archived?
      @framework.publish!
      flash[:success] = 'Framework unarchived successfully.'
    else
      flash[:failure] = 'Error unarchiving framework.'
    end
    redirect_to admin_framework_path(@framework)
  end

  def download_template
    resp = s3_client.get_object(bucket: bucket, key: @framework.file_key)
    send_data resp.body.read, filename: "#{@framework.full_name} Template#{File.extname(@framework.file_name.to_s)}"
  end

  private

  def filter_framework_status(scope)
    if params[:filters_applied].present?
      return scope unless params.key?(:framework_status)

      scope.where(aasm_state: params[:framework_status].map(&:downcase))
    else
      scope.where(aasm_state: %w[new published])
    end
  end

  def find_framework
    @framework = Framework.find(params[:id])
  end

  def prevent_republish
    return unless @framework.published?

    redirect_to admin_frameworks_path, alert: t('.cannot_change')
  end

  def framework_params
    params.require(:framework).permit(:definition_source, :template_file)
  end

  def excel_file?
    uploaded_file = params.require(:framework).require(:template_file)
    file_extension = File.extname(uploaded_file.original_filename)

    ['.xls', '.xlsx'].include?(file_extension)
  end

  def s3_client
    @s3_client ||= Aws::S3::Client.new(region: ENV['AWS_S3_REGION'])
  end

  def bucket
    ENV.fetch('AWS_S3_BUCKET')
  end
end
