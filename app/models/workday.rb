module Workday
  def self.configure
    yield self
  end

  def self.config
    @config ||= {}
  end

  def self.client
    @client ||= LolSoap::Client.new(File.read(wsdl_location))
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
    api_username.split('@').first if api_username.present?
  end

  def self.tenant
    api_username.split('@').last if api_username.present?
  end

  def self.wsdl_location
    if ENV['WORKDAY_TENANT'] == 'production'
      'data/production_workday_revenue_management_v31.0.xml'
    else
      'data/sandbox_workday_revenue_management_v31.0.xml'
    end
  end
end
