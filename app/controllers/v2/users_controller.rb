class V2::UsersController < ActionController::API
  include ApiKeyAuthenticatable

  def index
    @users = User.all
    render json: @users
  end
end
