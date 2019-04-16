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
    definition_source = framework_params[:definition_source]

    framework_def = begin
                      Framework::Definition::Language.generate_framework_definition(definition_source, logger)
                    rescue Parslet::ParseFailed => e
                      flash[:fdl_failure] = e.parse_failure_cause.ascii_tree
                      @framework = Framework.new(definition_source: definition_source)
                      render action: :new
                      return
                    end

    @framework = Framework.new(
      name:              framework_def.name,
      short_name:        framework_def.framework_short_name,
      definition_source: definition_source
    )

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

    definition_source = framework_params[:definition_source]

    framework_def = begin
      Framework::Definition::Language.generate_framework_definition(@framework.definition_source, logger)
    rescue Parslet::ParseFailed => e
      flash[:fdl_failure] = e.parse_failure_cause.ascii_tree
      render action: :edit
      return
    end

    if @framework.update(
      name:              framework_def.name,
      short_name:        framework_def.framework_short_name,
      definition_source: definition_source
    )
      flash[:success] = 'Framework saved successfully.'
      redirect_to admin_framework_path(@framework)
    else
      render action: :edit
    end
  end

  private

  def framework_params
    params.require(:framework).permit(:definition_source)
  end
end
