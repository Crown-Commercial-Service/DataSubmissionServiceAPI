class SyncUsersWithAuth0
  def self.run!
    client = Auth0Api.new.client
    User.active.each do |user|
      auth_id = client.get_users(q: "email:#{user.email}").first.fetch('user_id')
      user.update(auth_id: auth_id) if user.auth_id != auth_id
    end
  end
end
