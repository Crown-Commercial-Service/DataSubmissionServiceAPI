require 'custom_markdown_renderer'

class Admin::ReleaseNotesController < AdminController
  before_action :find_release_note, only: %i[show edit update publish]

  def index
    @release_notes = ReleaseNote.order(created_at: :desc).all
  end

  def new
    @release_note = ReleaseNote.new
  end

  def create
    @release_note = ReleaseNote.new(header: release_note_params[:header], body: release_note_params[:body])

    if @release_note.save
      flash[:success] = 'Release note created successfully.'
      redirect_to admin_release_notes_path
    else
      flash[:failure] = 'Could not save release note'
      render action: :new
    end
  end

  def preview
    markdown_parser = Redcarpet::Markdown.new(CustomMarkdownRenderer)
    @markdown_body = markdown_parser.render(params[:body])

    render json: { header: params[:header], body: @markdown_body }
  end

  def show
    markdown_parser = Redcarpet::Markdown.new(CustomMarkdownRenderer)
    @release_note_body = markdown_parser.render(@release_note[:body])
  end

  def edit; end

  def update
    if @release_note.update(release_note_params)
      flash[:success] = 'Release note updated successfully.'
      redirect_to admin_release_note_path(@release_note)
    else
      render action: :edit
    end
  end

  def publish
    if @release_note.publish!
      flash[:success] = 'Release note published successfully.'
      redirect_to admin_release_note_path(@release_note)
    else
      redirect_to admin_release_note_path(@release_note), alert: 'Unable to publish release note.'
    end
  end

  private

  def release_note_params
    params.require(:release_note).permit(:header, :body)
  end

  def find_release_note
    @release_note = ReleaseNote.find(params[:id])
  end
end