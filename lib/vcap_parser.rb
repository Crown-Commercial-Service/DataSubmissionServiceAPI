class VcapParser
  def self.load_service_environment_variables!
    return if ENV['VCAP_SERVICES'].blank?

    JSON.parse(ENV['VCAP_SERVICES']).fetch('user-provided').each do |service|
      service['credentials'].each_pair do |key, value|
        ENV[key] = value
      end
    end
  end
end
