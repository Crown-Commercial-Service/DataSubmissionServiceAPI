module Auth0Helpers
  def stub_auth0_token_request
    # The Auth0 v6 SDK automatically fetches the token and expects JSON with an expiry
    stub_request(:post, 'https://testdomain/oauth/token')
      .to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: {
          access_token: 'TOKEN',
          expires_in: 86400,
          token_type: 'Bearer'
        }.to_json
      )
  end

  def stub_auth0_delete_user_request(user)
    stub_request(:delete, "https://testdomain/api/v2/users/#{user.auth_id}")
      .to_return(status: 200, body: '')
  end

  def stub_auth0_delete_user_request_failure(user)
    stub_request(:delete, "https://testdomain/api/v2/users/#{user.auth_id}")
      .to_return(
        status: 400,
        headers: { 'Content-Type' => 'application/json' },
        body: { error: 'Internal Server Error', message: 'Something went wrong' }.to_json
      )
  end

  def stub_auth0_create_user_request(email)
    stub_request(:post, 'https://testdomain/api/v2/users')
      .with(body: hash_including(email: email))
      .to_return(status: 200, body: "{\"user_id\":\"auth0|#{email}\"}")
  end

  def stub_auth0_create_user_request_failure(email)
    stub_request(:post, 'https://testdomain/api/v2/users')
      .with(body: hash_including(email: email))
      .to_return(status: 400, body: '')
  end

  def stub_auth0_update_user_request(user)
    stub_request(:patch, "https://testdomain/api/v2/users/#{user.auth_id}")
      .to_return(status: 200, body: "{\"name\":\"#{user.name}\"}")
  end

  def stub_auth0_update_user_request_failure(user)
    stub_request(:patch, "https://testdomain/api/v2/users/#{user.auth_id}")
      .to_return(
        status: 400,
        headers: { 'Content-Type' => 'application/json' },
        body: { error: 'Internal Server Error', message: 'Something went wrong' }.to_json
      )
  end

  def stub_auth0_get_users_request(email:, auth_id: 'auth|123', user_already_exists: false)
    stubbed_response = if user_already_exists
                         [{ email: email, user_id: auth_id }]
                       else
                         []
                       end

    stub_request(:get, 'https://testdomain/api/v2/users')
      .with(query: hash_including(q: "email:#{email}"))
      .to_return(
        { status: 200, headers: { 'Content-Type' => 'application/json' }, body: { users: stubbed_response }.to_json },
        { status: 200, headers: { 'Content-Type' => 'application/json' }, body: { users: [] }.to_json }
      )
  end
end
