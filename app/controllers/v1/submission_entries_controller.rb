class V1::SubmissionEntriesController < APIController
  deserializable_resource :submission_entry, only: %i[create]

  skip_before_action :reject_without_user!, only: %i[create bulk]

  def create
    entry = initialize_submission_entry
    entry.attributes = IngestPostProcessor.new(
      params: submission_entry_params,
      framework: entry.submission.framework
    ).resolve_parameters

    return head :no_content if SubmissionEntry.exists?(submission_id: entry.submission_id, source: entry.source)

    if entry.save
      render jsonapi: entry, status: :created
    else
      render jsonapi_errors: entry.errors, status: :bad_request
    end
  end

  # rubocop:disable Metrics/AbcSize
  def bulk
    return render plain: 'success', status: :created if ENV['NEW_INGEST'] == 'true'

    entries = []

    params[:_jsonapi][:data].each do |entry_params|
      entry = initialize_submission_entry
      @framework ||= entry.submission.framework

      entry.attributes = IngestPostProcessor.new(
        params: params_from_bulk(entry_params),
        framework: @framework
      ).resolve_parameters

      entries << entry unless SubmissionEntry.exists?(submission_id: entry.submission_id, source: entry.source)
    end

    deduped_entries = entries.uniq { |entry| [entry.submission_id, entry.source] }
    SubmissionEntry.import(deduped_entries)

    render plain: 'success', status: :created
  end
  # rubocop:enable Metrics/AbcSize

  private

  def initialize_submission_entry
    if params[:file_id].present?
      @file ||= SubmissionFile.find(params[:file_id])
      @file.entries.new(submission_id: @file.submission_id)
    else
      @submission ||= Submission.find(params[:submission_id])
      @submission.entries.new
    end
  end

  def submission_entry_params
    params
      .require(:submission_entry)
      .permit(:entry_type, source: {}, data: {})
  end

  def params_from_bulk(entry_params)
    entry_params.require(:attributes).permit(:entry_type, source: {}, data: {})
  end
end
