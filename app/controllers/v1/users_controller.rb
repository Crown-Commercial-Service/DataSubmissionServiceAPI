class V1::UsersController < APIController
  def index
    users = User.where(nil)
    users = users.where(auth_id: params.dig(:filter, :auth_id)) if params.dig(:filter, :auth_id)
    render jsonapi: users
  end
end
