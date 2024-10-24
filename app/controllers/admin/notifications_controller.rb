require 'custom_markdown_renderer'

class Admin::NotificationsController < AdminController
  def index
    @published_notification = Notification.published.first
    @notifications = Notification.order(published_at: :desc).all
  end

  def new
    @notification = Notification.new
  end

  def show
    @notification = Notification.find(params[:id])
  end

  # rubocop:disable Metrics/AbcSize
  def create
    renderer = CustomMarkdownRenderer.new
    markdown_parser = Redcarpet::Markdown.new(renderer)
    html = markdown_parser.render(notification_params[:notification_message])
    @notification = Notification.new(summary: notification_params[:summary], notification_message: html,
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
  # rubocop:enable Metrics/AbcSize

  def preview
    renderer = CustomMarkdownRenderer.new
    markdown_parser = Redcarpet::Markdown.new(renderer)
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
