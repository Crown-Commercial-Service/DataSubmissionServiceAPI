require 'redcarpet'

class CustomMarkdownRenderer < Redcarpet::Render::HTML
  def link(link, title, content)
    "<a href=\"#{link}\" title=\"#{title}\" class=\"govuk-link\" target=\"_blank\">#{content}</a>"
  end

  def paragraph(content)
    "<p class=\"govuk-body\">#{content}</p>"
  end
end