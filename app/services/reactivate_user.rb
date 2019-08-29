class ReactivateUser
  attr_accessor :user

  def initialize(user:)
    self.user = user
  end

  def call
    result = Result.new(true)

    begin
      CreateUserInAuth0.new(user: user).call
    rescue Auth0::Exception
      result.success = false
      Rails.logger.error("Error adding user #{user.email} to Auth0 during ReactivateUser")
    end

    result
  end
end
