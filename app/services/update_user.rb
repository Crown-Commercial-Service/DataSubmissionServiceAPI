class UpdateUser
  attr_accessor :user

  def initialize(user, new_name)
    self.user = user
    @new_name = new_name
  end

  def call
    result = Result.new(true)

    User.transaction do
      user.update(name: @new_name)
      begin
        UpdateUserInAuth0.new(user: user).call
      rescue Auth0::Exception
        result.success = false
        Rails.logger.error("Error updating user name for #{user.email} in Auth0 during UpdateUser")
        raise ActiveRecord::Rollback
      end
    end

    result
  end
end
