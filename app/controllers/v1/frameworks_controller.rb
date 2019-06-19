class V1::FrameworksController < APIController
  skip_before_action :reject_without_user!

  def index
    frameworks = Framework.published.order(:short_name)

    render jsonapi: frameworks
  end
end
