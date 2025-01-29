class Admin::UsersController < AdminController
  before_action :find_user, only: %i[show edit update reactivate_user confirm_delete confirm_reactivate destroy]

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
    @memberships = @user.memberships.includes(:supplier)
  end

  def new
    @user = User.new
    @suppliers = Supplier.order(:name).search(params[:search]).page(params[:supplier_page])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    return redirect_to new_admin_user_path, alert: 'Email address already exists.' if existing_email?

    supplier_sf_ids = split_sf_ids(params[:supplier_salesforce_ids])
    if supplier_sf_ids.all?(&:blank?)
      return redirect_to new_admin_user_path, alert: 'You must select at least one supplier.'
    end

    begin
      import_user_with_suppliers(user_params, supplier_sf_ids)
      redirect_to admin_users_path, notice: 'User created successfully with linked suppliers.'
    rescue StandardError => e
      redirect_to new_admin_user_path, alert: "Failed to create user: #{e.message}"
    end
  end

  def edit; end

  def reactivate_user
    result = ReactivateUser.new(user: @user).call
    flash[:alert] = I18n.t('errors.messages.error_adding_user_to_auth0') if result.failure?

    redirect_to admin_user_path(@user)
  end

  def update
    result = UpdateUser.new(@user, user_params[:name]).call
    flash[:alert] = I18n.t('errors.messages.error_updating_user_in_auth0') if result.failure?

    redirect_to admin_user_path(@user)
  end

  def confirm_delete; end

  def confirm_reactivate; end

  def destroy
    DeactivateUser.new(user: @user).call
    flash[:alert] = 'User has been deactivated'
    redirect_to admin_users_path
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, supplier_salesforce_ids: [])
  end

  def find_user
    @user = User.find(params[:id])
  end

  def existing_email?
    User.find_by('lower(email) = ?', params[:user][:email].downcase)
  end

  def split_sf_ids(sf_ids)
    sf_ids.length === 1 ? sf_ids.first.split(',') : sf_ids # rubocop:disable Style/CaseEquality
  end

  def import_user_with_suppliers(user_data, supplier_sf_ids)
    supplier_sf_ids.each do |supplier_id|
      Import::Users::Row.new(email: user_data['email'], name: user_data['name'],
                             supplier_salesforce_id: supplier_id.strip).import!
    end
  end
end
