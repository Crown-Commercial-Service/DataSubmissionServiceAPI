class Admin::FrameworksController < AdminController
  before_action :prevent_change_to_published, only: %i[edit update]

  def index
    @frameworks = Framework.all
  end

  def new
    @framework = Framework.new
  end

  def show
    @framework = Framework.find(params[:id])
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
    if @framework.update_from_fdl(framework_params[:definition_source])
      flash[:success] = 'Framework saved successfully.'
      redirect_to admin_framework_path(@framework)
    else
      render action: :edit
    end
  end

  private

  def prevent_change_to_published
    @framework = Framework.find(params[:id]).tap do |framework|
      redirect_to admin_frameworks_path, alert: t('.cannot_change') if framework.published?
    end
  end

  def framework_params
    params.require(:framework).permit(:definition_source)
  end
end
