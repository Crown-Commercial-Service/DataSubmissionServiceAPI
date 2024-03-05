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

    resources :frameworks, only: %i[index show]

    resources :agreements, only: :index

    resources :customers, only: :index

    resource :customer_effort_scores, only: :create

    namespace :events do
      post 'user_signed_in'
      post 'user_signed_out'
    end
  end

  namespace :admin do
    root 'users#index'

    resources :users, only: %i[index show new create edit update destroy] do
      resources :memberships, only: %i[new create show destroy]
      member do
        post :reactivate_user
        get :confirm_delete
        get :confirm_reactivate
      end

      collection do
        resource :bulk_import, only: %i[new create], controller: 'user_bulk_imports', as: :user_bulk_import
        resource :bulk_deactivate, only: %i[new create], controller: 'user_bulk_deactivation', as: :user_bulk_deactivate
      end
    end

    resources :suppliers, only: %i[index show edit update] do
      member do
        get :show_tasks
        get :show_users
        get :show_frameworks
      end

      resources :agreements, only: [] do
        get :confirm_activation
        get :confirm_deactivation
        put :activate
        put :deactivate
      end
      resources :submissions, only: %i[show]
      resources :tasks, only: %i[new create]

      collection do
        resource :bulk_onboard, only: %i[new create],
                 controller: 'supplier_bulk_onboards',
                 as: :supplier_bulk_onboard

        resource :bulk_remove_from_lots, only: %i[new create],
                 controller: 'supplier_bulk_lot_removal',
                 as: :supplier_bulk_lot_removal

        resource :bulk_deactivate, only: %i[new create],
                 controller: 'supplier_bulk_deactivation',
                 as: :supplier_bulk_deactivate
      end
    end

    resources :tasks, only: [] do
      resources :submission, only: [], controller: 'submission_download' do
        get 'download'
      end
    end

    resources :frameworks, only: %i[index new create show edit update] do
      resources :reports, only: [], controller: 'frameworks/reports' do
        collection do
          get :users
          get :lots
        end
      end

      member do
        patch :update_fdl
        patch :publish
        get :download_template
      end
    end

    resources :urn_lists, only: %i[index new create] do
      member do
        get :download
      end
    end

    resources :downloads, only: %i[index show new]

    resources :unfinished_tasks, only: %i[index]

    get '/sign_in', to: 'sessions#new', as: :sign_in
    get '/sign_out', to: 'sessions#destroy', as: :sign_out
  end

  get '/auth/:provider/callback', to: 'admin/sessions#create'
  # The "POST" version of the callback is required for OmniAuth::Strategies::DeveloperAdmin
  post '/auth/:provider/callback', to: 'admin/sessions#create' if OmniAuth::Strategies::DeveloperAdmin.applies?
end
