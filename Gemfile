source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.7'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.4.6'

# State machine
gem 'aasm'

gem 'bootsnap', '>= 1.1.0', require: false

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# JSON API
gem 'jsonapi-rails'

gem 'jquery-rails', '>= 4.4.0'

# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'

# Use Puma as the app server
gem 'puma', '~> 5.5'

# Audit log
gem 'rails_event_store'

# Auth0
gem 'auth0', require: false

# Google Login
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection', '~> 1.0', '>= 1.0.0'

# Admin Frontend
gem 'haml-rails', '>= 1.0.0'
gem 'sass-rails', '~> 5.0', '>= 5.0.7'
gem 'uglifier', '>= 1.3.0'
gem 'kaminari', '>= 1.2.1'
gem 'simple_form', '>= 5.0.0'

gem 'aws-sdk-cloudwatch', require: false
gem 'aws-sdk-s3', require: false
gem 'azure-storage-blob', '>= 1.1.0', require: false

# Exception tracking
gem 'rollbar'

# Logging
gem 'lograge', '>= 0.10.0'
gem 'skylight', '4.0.0.alpha'

gem 'rubocop'
gem 'rubocop-rails', '~> 2.10', '>= 2.10.1'

gem 'progress_bar', require: false

gem 'sidekiq', '>= 6.2.1'
gem 'sidekiq-cron', '>= 1.0.4'

gem 'activerecord-import'

gem 'parslet'

# SOAP-related libraries for Workday integration
gem 'lolsoap', '>= 0.9.0', require: false
gem 'akami', '>= 1.3.1', require: false
gem 'http', '>= 4.0.0'

# Used for FDL testing (see FDL::Validations::Test)
gem 'hashdiff', require: false

group :development, :test do
  gem 'brakeman', require: false
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails', '>= 2.4.0'
  gem 'factory_bot_rails', '>= 4.10.0'
  gem 'pry-rails'
  gem 'rspec-rails', '>= 3.7.2'
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
  gem 'ruby_event_store-rspec'
  gem 'rspec-json_expectations'
  gem 'shoulda-matchers'
  gem 'capybara', '>= 3.35.3'
  gem 'climate_control'
  gem 'webmock', '>= 3.4.2'
  gem 'launchy', '>= 2.4.3'
  gem 'simplecov', '0.17', require: false # SimpleCov 0.18+ not yet supported by Codeclimate
end
