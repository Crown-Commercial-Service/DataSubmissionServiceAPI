class V1::EventsController < APIController
  skip_before_action :reject_without_user!

  def user_signed_in
    @user = User.find_by(auth_id: event_params[:user_id])
    add_user_session(@user) if @user

    event_store.publish_event(
      UserSignedIn.new(
        data: { user_id: event_params[:user_id] }
      )
    )

    head :created
  end

  def user_signed_out
    remove_user_session(event_params[:user_id])

    event_store.publish_event(
      UserSignedOut.new(
        data: { user_id: event_params[:user_id] }
      )
    )

    head :created
  end

  def user_terminated
    remove_user_session(event_params[:user_id])

    event_store.publish_event(
      UserTerminated.new(
        data: { user_id: event_params[:user_id] }
      )
    )

    head :created
  end

  private

  def add_user_session(user)
    # rubocop:disable Style/BracesAroundHashParameters
    SessionStore.add(
      {
        user_id: user[:id],
        auth_id: user[:auth_id],
        name: user[:name],
        email: user[:email]
      }
    )
    # rubocop:enable Style/BracesAroundHashParameters
  end

  def remove_user_session(id)
    index = 0
    SessionStore.sessions_array_data.each do |e|
      SessionStore.sessions_array_data.delete_at(index) if id == e[:auth_id]
      index += 1
    end
  end

  def event_params
    params.permit(:user_id)
  end

  def event_store
    RailsEventStore::Client.new
  end
end
