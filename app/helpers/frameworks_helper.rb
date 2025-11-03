module FrameworksHelper
  def published_status(framework)
    framework.aasm_state
  end

  def framework_not_archived?(framework)
    framework.aasm_state != 'archived'
  end
end
