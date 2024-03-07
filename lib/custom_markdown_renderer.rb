require 'redcarpet'

class CustomMarkdownRenderer < Redcarpet::Render::HTML
  def link(link, title, content)
    "<a href=\"#{link}\" title=\"#{title}\" class=\"govuk-notification-banner__link\" target=\"_blank\">#{content}</a>"
  end

  def paragraph(content)
    "<p class=\"govuk-notification-banner__heading\">#{content}</p>"
  end
end