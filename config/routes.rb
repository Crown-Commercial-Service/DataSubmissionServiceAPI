Rails.application.routes.draw do
  require 'sidekiq/web'
  require 'sidekiq/cron/web'

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    # Protect against timing attacks:
    # - See https://codahale.com/a-lesson-in-timing-attacks/
    # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
    # - Use & (do not use &&) so that it doesn't short circuit.
    # - Use digests to stop length information leaking
    # (see also ActiveSupport::SecurityUtils.variable_size_secure_compare)
    ActiveSupport::SecurityUtils.secure_compare(
      ::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_USERNAME'])
    ) &
      ActiveSupport::SecurityUtils.secure_compare(
        ::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_PASSWORD'])
      )
  end
  mount Sidekiq::Web, at: '/admin/sidekiq'
  # Endpoint for Cloudwatch to check API is up and running
  get '/check', to: 'check#index', defaults: { format: :json }

  namespace :v1, defaults: { format: :json } do
    resources :users, only: %i[index]

    resources :submissions, only: %i[show create update] do
      member do
        post 'complete', to: 'submissions#complete'
        post :validate
      end

      resources :files, only: %i[create update show], controller: 'submission_files'
      resources :entries, only: %i[create], controller: 'submission_entries' do
        collection do
          post :bulk
        end
      end
    end
    resources :tasks, only: %i[index show update] do
      member do
        post :complete
        post :no_business
      end
    end

    resources :files, only: [] do
      resources :entries, only: %i[create], controller: 'submission_entries' do
        collection do
          post :bulk
        end
      end
      resources :blobs, only: :create, controller: 'submission_file_blobs'
    end

    namespace :events do
      post 'user_signed_in'
      post 'user_signed_out'
    end
  end

  namespace :admin do
    root 'users#index'
    resources :users, only: %i[index show new create destroy] do
      resources :memberships, only: %i[new create show destroy]
      member do
        post :edit
        get :confirm_delete
        get :confirm_reactivate
      end
    end
    resources :suppliers, only: %i[index show]
    get '/sign_in', to: 'sessions#new', as: :sign_in
    get '/sign_out', to: 'sessions#destroy', as: :sign_out
  end

  get '/auth/:provider/callback', to: 'admin/sessions#create'
  # The "POST" version of the callback is required for OmniAuth::Strategies::DeveloperAdmin
  post '/auth/:provider/callback', to: 'admin/sessions#create' if OmniAuth::Strategies::DeveloperAdmin.applies?
end
