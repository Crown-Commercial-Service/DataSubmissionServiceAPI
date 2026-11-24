class DeactivateUser
  attr_accessor :user

  def initialize(user:)
    self.user = user
  end

  def call
    result = Result.new(true)

    User.transaction do
      lock_linked_suppliers!

      unless user.can_deactivate?
        result.success = false
        raise ActiveRecord::Rollback
      end

      begin
        DeleteUserInAuth0.new(user: user).call
      rescue Auth0::Errors::ApiError
        result.success = false
        Rails.logger.error("Error adding user #{user.email} to Auth0 during DeactivateUser")
        raise ActiveRecord::Rollback
      end

      unless user.update(auth_id: nil)
        result.success = false
        raise ActiveRecord::Rollback
      end
    end

    result
  end

  private

  def lock_linked_suppliers!
    user.suppliers.lock.load
  end
end
