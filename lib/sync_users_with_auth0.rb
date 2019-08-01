class SyncUsersWithAuth0
  def self.run!
    client = Auth0Api.new.client
    User.active.each do |user|
      response = client.get_users(q: "email:#{user.email}")
      return Rails.logger.info("Email: #{user.email} could not be found in Auth0") if response.empty?

      auth_id = response.first.fetch('user_id')
      user.update(auth_id: auth_id) if user.auth_id != auth_id
    end
  end
end
