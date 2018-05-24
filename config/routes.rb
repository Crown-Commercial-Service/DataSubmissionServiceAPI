Rails.application.routes.draw do
  # Endpoint for Cloudwatch to check API is up and running
  get '/check', to: 'check#index', defaults: { format: :json }
end
