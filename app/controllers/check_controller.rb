class CheckController < APIController
  skip_before_action :reject_without_user!

  def index
    # NO OP
  end
end
