class CheckController < APIController
  skip_before_action :authenticate
  def index
    # NO OP
  end
end
