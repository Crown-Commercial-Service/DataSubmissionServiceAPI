class Admin::FrameworksController < AdminController
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
      flash[:fdl_failure] = @framework.errors[:definition_source].first
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

  def edit
    @framework = Framework.find(params[:id])
  end

  def update
    @framework = Framework.find(params[:id])

    if @framework.update_from_fdl(framework_params[:definition_source])
      flash[:success] = 'Framework saved successfully.'
      redirect_to admin_framework_path(@framework)
    else
      flash[:fdl_failure] = @framework.errors[:definition_source].first
      render action: :edit
    end
  end

  private

  def framework_params
    params.require(:framework).permit(:definition_source)
  end
end
