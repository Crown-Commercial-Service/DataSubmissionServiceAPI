Rails.application.routes.draw do
  # Endpoint for Cloudwatch to check API is up and running
  get '/check', to: 'check#index', defaults: { format: :json }

  namespace :v1, defaults: { format: :json } do
    resources :frameworks, only: %i[index show]
    resources :suppliers, only: %i[index]
    resources :agreements, only: %i[create]
    resources :submissions, only: %i[create] do
      resources :files, only: %i[create], controller: 'submission_files'
      resources :entries, only: %i[create], controller: 'submission_entries'
    end
    resources :tasks, only: %i[create index] do
      member do
        post 'complete', to: 'tasks#complete'
      end
    end

    resources :files, only: [] do
      resources :entries, only: %i[create], controller: 'submission_entries'
    end

    namespace :events do
      post 'user_signed_in'
      post 'user_signed_out'
    end
  end
end
