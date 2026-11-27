require './lib/auth0_api'

class UserLogsInAuth0
  attr_accessor :user

  def initialize(user:)
    self.user = user
  end

  def call
    query = "(type:\"s\" OR type:\"f\") AND user_id:\"#{user.auth_id}\""
    auth0_client.logs.list(
      q: query,
      per_page: 5,
      sort: 'date:-1'
    ).to_a
  end

  private

  def auth0_client
    @auth0_client ||= Auth0Api.new.client
  end
end
