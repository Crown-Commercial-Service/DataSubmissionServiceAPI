class Admin::FrameworksController < AdminController
  def index
    @frameworks = Framework.all
  end
end
