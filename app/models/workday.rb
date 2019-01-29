module Workday
  def self.configure
    yield self
  end

  def self.config
    @config ||= {}
  end

  def self.client
    @client ||= LolSoap::Client.new(File.read('data/workday_revenue_management_v31.0.xml'))
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

  def self.username
    api_username.split('@').first
  end

  def self.tenant
    api_username.split('@').last
  end
end
