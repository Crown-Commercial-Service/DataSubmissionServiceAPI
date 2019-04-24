module FrameworksHelper
  def published_status(framework)
    framework.published ? 'Published' : 'New'
  end
end
