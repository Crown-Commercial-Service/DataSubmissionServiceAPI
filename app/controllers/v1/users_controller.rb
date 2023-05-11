class V1::UsersController < ApiController
  def index
    users = User.where(auth_id: current_auth_id)

    render jsonapi: users
  end
end
