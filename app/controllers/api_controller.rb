class APIController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  http_basic_authenticate_with name: "dxw", password: ENV['API_PASSWORD'] if ENV['API_PASSWORD']
end
