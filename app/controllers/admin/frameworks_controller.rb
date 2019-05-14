class Admin::FrameworksController < AdminController
  before_action :find_framework, only: %i[show edit update update_fdl publish]
  before_action :prevent_change_to_published, only: %i[edit update_fdl publish]

  def index
    @frameworks = Framework.order(:short_name).all
  end

  def new
    @framework = Framework.new
  end

  def show; end

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
    @framework.update!(framework_params)
    flash[:success] = 'Framework saved successfully.'
    redirect_to admin_framework_path(@framework)
  end

  def update_fdl
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

  private

  def find_framework
    @framework = Framework.find(params[:id])
  end

  def prevent_change_to_published
    return unless @framework.published?

    redirect_to admin_frameworks_path, alert: t('.cannot_change')
  end

  def framework_params
    params.require(:framework).permit(:definition_source, :template_file)
  end
end
