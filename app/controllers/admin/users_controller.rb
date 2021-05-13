class Admin::UsersController < AdminController
  def index
    @users = User.search(params[:search]).page(params[:page])
    # The following block (Lines 8 to 11), will check for stuck submissions in 'processing' longer than 24hrs.
    # These submissions are collated into array 'submissions_stuck'. If non-empty, this array is then looped
    # through to update them as 'failed' (in a database query), to then be resubmitted by a supplier (or not).
    # rubocop:disable Metrics/LineLength
    submissions_stuck = Submission.joins(:task).where("aasm_state = 'processing' and submissions.updated_at < ? and tasks.status != 'completed'", Time.zone.now - 1.day)
    # rubocop:enable Metrics/LineLength
    submissions_stuck.each { |s| s.update!(aasm_state: :ingest_failed) } if submissions_stuck.length.positive?
  end

  def show
    # redirect route in case of attempt to visit deprecated paths
    return redirect_to admin_root_path if ['new', 'bulk_import'].include?(params[:id])
    @user = User.find(params[:id])
    @memberships = @user.memberships.includes(:supplier)
  end
end
