Rails.application.routes.draw do
  # Endpoint for Cloudwatch to check API is up and running
  get '/check', to: 'check#index', defaults: { format: :json }

  namespace :v1, defaults: { format: :json } do
    resources :frameworks, only: %i[index show]
    resources :suppliers, only: %i[index]
    resources :agreements, only: %i[create]
    resources :users, only: %i[index]
    resources :submissions, only: %i[show create update] do
      member do
        post 'complete', to: 'submissions#complete'
        post :validate
      end

      resources :files, only: %i[create update show], controller: 'submission_files'
      resources :entries, only: %i[create], controller: 'submission_entries'
    end
    resources :tasks, only: %i[index show create update] do
      member do
        post :complete
        post :no_business
      end
    end

    resources :files, only: [] do
      resources :entries, only: %i[show create], controller: 'submission_entries'
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
        get :confirm_delete
      end
    end
    get '/sign_in', to: 'sessions#new', as: :sign_in
    get '/sign_out', to: 'sessions#destroy', as: :sign_out
  end

  get '/auth/:provider/callback', to: 'admin/sessions#create'
end
