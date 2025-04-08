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
    @user = User.new(user_params)
  rescue
    @user = User.new
  end

  def build
    @user = User.new(user_params)

    if @user.valid?
      @suppliers = Supplier.order(:name).search(params[:search]).page(params[:supplier_page])
      respond_to do |format|
        format.html { render :select_suppliers }
        format.js { render :select_suppliers }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def validate_suppliers
    @user = User.new(user_params)
    @selected_supplier_ids = Array(params[:supplier_salesforce_ids]).uniq

    if @selected_supplier_ids.empty?
      flash[:failure] = 'You must select at least one supplier.'
      @suppliers = Supplier.order(:name).search(params[:search]).page(params[:supplier_page])
      render :select_suppliers, status: :unprocessable_entity
    else
      @suppliers = Supplier.where(salesforce_id: @selected_supplier_ids)
      render :confirm
    end
  end

  def create
    supplier_sf_ids = params[:supplier_salesforce_ids].uniq
    
    begin
      import_user_with_suppliers(params[:name], params[:email], supplier_sf_ids)

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

  def import_user_with_suppliers(name, email, supplier_sf_ids)
    supplier_sf_ids.each do |supplier_id|
      Import::Users::Row.new(email: email, name: name,
                             supplier_salesforce_id: supplier_id.strip).import!
    end
  end
end
