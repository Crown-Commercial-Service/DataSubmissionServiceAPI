module Auth0Helpers
  def stub_auth0_token_request
    stub_request(:post, 'https://testdomain/oauth/token')
      .to_return(status: 200, body: '{"access_token":"TOKEN"}')
  end

  def stub_auth0_delete_user_request(user)
    stub_request(:delete, "https://testdomain/api/v2/users/#{user.auth_id}")
      .to_return(status: 200, body: '')
  end
end
