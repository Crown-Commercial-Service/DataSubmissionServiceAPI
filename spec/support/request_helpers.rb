require 'jwt'

module RequestHelpers
  def json
    JSON.parse(response.body)
  end

  def json_headers
    { 'Content-Type': 'application/vnd.api+json', 'Accept': 'application/vnd.api+json' }
  end

  def auth_header(user)
    payload = {
      name: user.email,
      iss: "https://#{ENV['AUTH0_DOMAIN']}",
      sub: user.auth_id,
      iat: Time.zone.now.to_i,
      exp: 10.hours.from_now.to_i
    }

    private_key = OpenSSL::PKey.read(File.read(Rails.root.join('spec', 'fixtures', 'jwtRS256.key')))

    token = JWT.encode(payload, private_key, 'RS256')

    { 'Authorization': "Bearer #{token}" }
  end
end
