class CreateUser
  attr_accessor :user

  def initialize(user:)
    self.user = user
  end

  def call
    result = Result.new(true)

    User.transaction do
      user.save
      begin
        CreateUserInAuth0.new(user: user).call
      rescue Auth0::Exception
        result.success = false
        Rails.logger.error("Error adding user #{user.email} to Auth0 during CreateUser")
        raise ActiveRecord::Rollback
      end
    end

    result
  end
end
