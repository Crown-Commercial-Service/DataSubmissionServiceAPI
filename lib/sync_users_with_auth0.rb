require 'auth0'

class SyncUsersWithAuth0
  class << self
    def run!(dry: false)
      User.active.each do |user|
        delay_request unless Rails.env.test?

        response = auth0_client.get_users(q: "email:#{user.email}")

        if response.empty?
          Rails.logger.info("Email: #{user.email} could not be found in Auth0")
          next
        end

        update_user(user: user, response: response, dry: dry)
      end
    end

    def delay_request
      sleep 0.1
    end

    private

    def auth0_client
      @auth0_client ||= Auth0Api.new.client
    end

    def update_user(user:, response:, dry:)
      auth_id = response.first.fetch('user_id')
      return if user.auth_id == auth_id

      if dry
        Rails.logger.info("Would have updated (#{user.email}) to (#{auth_id}).")
      else
        user.update(auth_id: auth_id)
        Rails.logger.info("Updated (#{user.email}) to (#{auth_id}).")
      end
    end
  end
end
