class UpdateUserEmail
  include ActiveModel::Validations

  def initialize(user, new_email)
    @user = user
    @new_email = new_email
  end

  def call
    User.transaction do
      update_user_record
      sync_with_auth0
    end
    errors.empty?
  end

  private

  def update_user_record
    return if @user.update(email: @new_email)

    @user.errors.each { |error| errors.add(error.attribute, error.message) }
    raise ActiveRecord::Rollback
  end

  def sync_with_auth0
    UpdateUserEmailInAuth0.new(user: @user).call
    SendConfirmEmailVerificationJob.perform_later(new_email: @new_email, person_name: @user.name)
  rescue Auth0::Errors::ApiError => e
    errors.add(:base, "Auth0 update failed: #{e.message}")
    Rails.logger.error("Auth0 Error: #{e.message}")
    raise ActiveRecord::Rollback
  end
end
