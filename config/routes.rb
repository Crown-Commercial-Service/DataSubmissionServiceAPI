Rails.application.routes.draw do
  # Endpoint for Cloudwatch to check API is up and running
  get '/check', to: 'check#index', defaults: { format: :json }

  namespace :v1, defaults: { format: :json } do
    resources :frameworks, only: %i[index show]
    resources :suppliers, only: %i[index show]
  end
end
