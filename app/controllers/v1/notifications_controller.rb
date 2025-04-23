require 'custom_markdown_renderer'

class V1::NotificationsController < ApiController
  def index
    markdown_parser = Redcarpet::Markdown.new(CustomMarkdownRenderer)
    notifications = Notification.published.first
    notifications[:notification_message] = markdown_parser.render(notifications[:notification_message]) if notifications

    render jsonapi: notifications
  end
end
