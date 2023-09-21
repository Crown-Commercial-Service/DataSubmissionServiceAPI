class Auth
  ALGORITHM = 'HS256'.freeze

  def self.decode(token)
    JWT.decode(token, 
        auth_secret, 
        true, 
        { algorithm: ALGORITHM }).first
  end

  def self.auth_secret
    ENV["AUTH_SECRET"]
  end
end