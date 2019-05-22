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
      end

      resources :files, only: %i[create update show], controller: 'submission_files'
    end
    resources :tasks, only: %i[index show update] do
      member do
        post :complete
        post :no_business
        patch :cancel_correction
      end
    end

    resources :files, only: [] do
      resources :blobs, only: :create, controller: 'submission_file_blobs'
    end

    resources :frameworks, only: :index

    resources :urn_lists, only: :index

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

      collection do
        resource :bulk_import, only: %i[new create], controller: 'user_bulk_imports', as: :user_bulk_import
      end
    end

    resources :suppliers, only: %i[index show edit update] do
      resources :agreements, only: [] do
        get :confirm_activation
        get :confirm_deactivation
        put :activate
        put :deactivate
      end
      resources :submissions, only: %i[show]

      collection do
        resource :bulk_import, only: %i[new create], controller: 'supplier_bulk_imports', as: :supplier_bulk_import
      end
    end

    resources :tasks, only: [] do
      get 'active_submission/download'
    end

    resources :frameworks, only: %i[index new create show edit update] do
      member do
        patch :update_fdl
        patch :publish
      end
    end

    resources :urn_lists, only: %i[index new create]

    resources :notify_downloads, only: %i[index show]

    get '/sign_in', to: 'sessions#new', as: :sign_in
    get '/sign_out', to: 'sessions#destroy', as: :sign_out
  end

  get '/auth/:provider/callback', to: 'admin/sessions#create'
  # The "POST" version of the callback is required for OmniAuth::Strategies::DeveloperAdmin
  post '/auth/:provider/callback', to: 'admin/sessions#create' if OmniAuth::Strategies::DeveloperAdmin.applies?
end
