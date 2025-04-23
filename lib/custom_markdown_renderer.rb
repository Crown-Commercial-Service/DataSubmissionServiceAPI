require 'redcarpet'

class CustomMarkdownRenderer < Redcarpet::Render::HTML
  def link(link, title, content)
    "<a href=\"#{link}\" title=\"#{title}\" class=\"govuk-link\" target=\"_blank\">#{content}</a>"
  end

  def paragraph(content)
    "<p class=\"govuk-body\">#{content}</p>"
  end

  def header(text, header_level)
    govuk_heading_class = case header_level
                          when 1 then 'govuk-heading-xl'
                          when 2 then 'govuk-heading-l'
                          when 3 then 'govuk-heading-m'
                          when 4 then 'govuk-heading-s'
                          else 'govuk-heading-s'
                          end
    "<h#{header_level} class=\"#{govuk_heading_class}\">#{text}</h#{header_level}>"
  end

  def list(contents, list_type)
    list_tag = list_type == :ordered ? 'ol' : 'ul'
    govuk_list_class = list_type == :ordered ? 'govuk-list--number' : 'govuk-list--bullet'
    "<#{list_tag} class=\"govuk-list #{govuk_list_class}\">#{contents}</#{list_tag}>"
  end
end