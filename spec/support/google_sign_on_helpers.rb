module SingleSignOnHelpers
  def mock_sso_with(email: 'john@example.com', uid: '123456')
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      'provider' => 'google_oauth2',
      'uid' => uid,
      'info' => {
        'name' => 'John Smith',
        'email' => email,
        'first_name' => 'John',
        'last_name' => 'Smith',
        'image' => 'https://lh4.googleusercontent.com/photo.jpg',
        'urls' => {
          'google' => 'https://plus.google.com/+JohnSmith'
        }
      },
      'credentials' => {
        'token' => 'TOKEN',
        'refresh_token' => 'REFRESH_TOKEN',
        'expires_at' => 1496120719,
        'expires' => true
      },
      'extra' => {
        'id_token' => 'ID_TOKEN',
        'id_info' => {
          'azp' => 'APP_ID',
          'aud' => 'APP_ID',
          'sub' => '100000000000000000000',
          'email' => 'john@example.com',
          'email_verified' => true,
          'at_hash' => 'HK6E_P6Dh8Y93mRNtsDB1Q',
          'iss' => 'accounts.google.com',
          'iat' => 1496117119,
          'exp' => 1496120719
        },
        'raw_info' => {
          'kind' => 'plus#personOpenIdConnect',
          'gender' => 'male',
          'sub' => '100000000000000000000',
          'name' => 'John Smith',
          'given_name' => 'John',
          'family_name' => 'Smith',
          'profile' => 'https://plus.google.com/+JohnSmith',
          'picture' => 'https://lh4.googleusercontent.com/photo.jpg?sz=50',
          'email' => 'john@example.com',
          'email_verified' => 'true',
          'locale' => 'en',
          'hd' => 'company.com'
        }
      }
    )
  end
end
