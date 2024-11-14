require 'custom_markdown_renderer'

class Admin::NotificationsController < AdminController
  def index
    markdown_parser = Redcarpet::Markdown.new(CustomMarkdownRenderer)
    @published_notification = Notification.published.first
    @published_notification_message = markdown_parser.render(@published_notification[:notification_message]) if @published_notification
    @notifications = Notification.order(published_at: :desc).all
  end

  def new
    @notification = Notification.new
    @published_notification = Notification.find(params[:published_notification]) if params[:published_notification]
  end

  def show
    markdown_parser = Redcarpet::Markdown.new(CustomMarkdownRenderer)
    @notification = Notification.find(params[:id])
    @notification_message = markdown_parser.render(@notification[:notification_message])
  end

  def create
    @notification = Notification.new(summary: notification_params[:summary], notification_message: notification_params[:notification_message],
                                     user: current_user['email'], published: true, published_at: Time.zone.now)
    Notification.transaction do
      if @notification.save
        flash[:success] = 'Notification created successfully.'
        redirect_to admin_notifications_path
      else
        @notification.assign_attributes(notification_message: notification_params[:notification_message])
        render action: :new
      end
    end
  end

  def preview
    markdown_parser = Redcarpet::Markdown.new(CustomMarkdownRenderer)
    @markdown_message = markdown_parser.render(params[:message])

    render json: { summary: params[:summary], message: @markdown_message }
  end

  def unpublish
    @notification = Notification.find(params[:id])
    if @notification.unpublish!
      redirect_to admin_notifications_path, notice: 'Notification was successfully unpublished.'
    else
      redirect_to admin_notifications_path, alert: 'Unable to unpublish notification.'
    end
  end

  private

  def notification_params
    params.require(:notification).permit(:summary, :notification_message)
  end
end
