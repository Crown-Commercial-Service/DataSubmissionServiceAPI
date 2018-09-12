require 'csv'
require 'auth0'
require 'user_import_row'

class UserImport
  def initialize(csv_data, auth0_client, auth0_throttle_sleep: 1)
    @rows = CSV.parse(csv_data, headers: true, header_converters: :symbol)
    @auth0_client = auth0_client
    @auth0_throttle_sleep = auth0_throttle_sleep
  end

  def run!
    @rows.each do |row|
      UserImportRow.new(row.to_h, @auth0_client).import!

      # Needed to stop the Auth0 Management API throttling us
      sleep(@auth0_throttle_sleep)
    end
  end
end
