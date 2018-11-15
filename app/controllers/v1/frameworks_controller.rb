class V1::FrameworksController < APIController
  def index
    render jsonapi: Framework.all
  end

  def show
    render jsonapi: Framework.find(params[:id])
  end
end
