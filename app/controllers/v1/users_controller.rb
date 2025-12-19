class V1::UsersController < ApiController
  def index
    users = User.where(auth_id: current_auth_id)

    render jsonapi: users
  end

  def update_name
    user = User.find_by!(auth_id: current_auth_id)
    name_param = params.dig('_jsonapi', 'name')
    result = UpdateUser.new(user, name_param).call

    if result.success?
      render jsonapi: user, status: :ok
    else
      render jsonapi_errors: { error: I18n.t('errors.messages.error_updating_user_in_auth0') },
             status: :unprocessable_entity
    end
  end
end
