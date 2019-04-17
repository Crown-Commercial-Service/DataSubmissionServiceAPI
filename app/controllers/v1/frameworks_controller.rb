class V1::FrameworksController < APIController
  skip_before_action :authenticate, :reject_without_user!

  def index
    frameworks = Framework.all.sort_by(&:short_name)

    render jsonapi: frameworks
  end
end
