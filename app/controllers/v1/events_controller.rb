class V1::EventsController < APIController
  skip_before_action :reject_without_user!

  def user_signed_in
    event_store.publish_event(
      UserSignedIn.new(
        data: { user_id: event_params[:user_id] }
      )
    )

    head :created
  end

  def user_signed_out
    event_store.publish_event(
      UserSignedOut.new(
        data: { user_id: event_params[:user_id] }
      )
    )

    head :created
  end

  private

  def event_params
    params.permit(:user_id)
  end

  def event_store
    RailsEventStore::Client.new
  end
end
