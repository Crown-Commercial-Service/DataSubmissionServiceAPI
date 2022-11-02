class V1::FrameworksController < APIController
  skip_before_action :authenticate, :reject_without_user!

  def index
    frameworks = Framework.published.order(:short_name)

    render jsonapi: frameworks
  end

  def show
    framework = Framework.find(params[:id])

    render jsonapi: framework, include: params[:include], expose: { include_file: params[:include_file] }
  end
end
