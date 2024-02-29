class V1::NotificationsController < ApiController
  def index 
    notifications = Notification.published.first
    
    render jsonapi: notifications
  end
end