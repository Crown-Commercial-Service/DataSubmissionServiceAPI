require 'custom_markdown_renderer'

class V1::ReleaseNotesController < ApiController
  def index
    release_notes = ReleaseNote.published.order(created_at: :desc)

    release_notes.each do |release_note|
      release_note[:body] = render_markdown(release_note[:body]) if release_notes
    end

    render jsonapi: release_notes
  end

  def show
    release_note = ReleaseNote.find(params[:id])
    release_note[:body] = render_markdown(release_note[:body]) if release_note

    render jsonapi: release_note
  end

  private

  def render_markdown(markdown)
    markdown_parser = Redcarpet::Markdown.new(CustomMarkdownRenderer)
    markdown_parser.render(markdown)
  end
end
