module Workday
  def self.configure
    yield self
  end

  def self.config
    @config ||= {}
  end

  def self.api_username=(username)
    config[:username] = username
  end

  def self.api_username
    config[:username]
  end

  def self.api_password=(password)
    config[:password] = password
  end

  def self.api_password
    config[:password]
  end
end
