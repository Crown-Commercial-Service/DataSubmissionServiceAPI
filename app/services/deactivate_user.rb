class DeactivateUser
  attr_accessor :user

  def initialize(user:)
    self.user = user
  end

  def call
    result = Result.new(true)

    User.transaction do
      begin
        DeleteUserInAuth0.new(user: user).call
      rescue Auth0::Exception
        result.success = false
        Rails.logger.error("Error adding user #{user.email} to Auth0 during DeactivateUser")
        raise ActiveRecord::Rollback
      end
      user.update(auth_id: nil)
    end

    result
  end
end
