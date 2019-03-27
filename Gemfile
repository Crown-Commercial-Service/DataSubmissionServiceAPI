source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.2'

# State machine
gem 'aasm'

gem 'bootsnap', '>= 1.1.0', require: false

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# JSON API
gem 'jsonapi-rails'

# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'

# Use Puma as the app server
gem 'puma', '~> 3.11'

# Audit log
gem 'rails_event_store'

# Auth0
gem 'auth0', require: false

# Google Login
gem 'omniauth-google-oauth2'

# Admin Frontend
gem 'haml-rails'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'kaminari'
gem 'simple_form'

gem 'aws-sdk-cloudwatch', require: false
gem 'aws-sdk-s3', require: false

# Exception tracking
gem 'rollbar'

# Logging
gem 'lograge'
gem 'skylight', '4.0.0.alpha'

gem 'rubocop'

gem 'progress_bar', require: false

gem 'sidekiq'
gem 'sidekiq-cron'

gem 'activerecord-import'

gem 'parslet'

# SOAP-related libraries for Workday integration
gem 'lolsoap', require: false
gem 'akami', require: false
gem 'http'

# Used for FDL testing (see FDL::Validations::Test)
gem 'hashdiff', require: false

group :development, :test do
  gem 'brakeman', require: false
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'pry-rails'
  gem 'rspec-rails'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'database_cleaner'
  gem 'jsonapi-rspec', require: false
  gem 'rails_event_store-rspec'
  gem 'rspec-json_expectations'
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'climate_control'
  gem 'webmock'
end
