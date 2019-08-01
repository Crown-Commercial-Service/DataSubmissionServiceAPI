require 'auth0'

class SyncUsersWithAuth0
  def self.run!(dry: false)
    client = Auth0Api.new.client
    User.active.each do |user|
      delay_request unless Rails.env.test?

      response = client.get_users(q: "email:#{user.email}")
      return Rails.logger.info("Email: #{user.email} could not be found in Auth0") if response.empty?

      auth_id = response.first.fetch('user_id')

      if user.auth_id != auth_id
        if dry
          Rails.logger.info("Would have updated (#{user.email}) to (#{auth_id}).")
        else
          user.update(auth_id: auth_id)
        end
      end
    end
  end

  def self.delay_request
    sleep 0.1
  end
end
