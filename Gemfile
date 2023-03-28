source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.6'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1.7.3'

# State machine
gem 'aasm'

gem 'bootsnap', '~> 1.11', '>= 1.11.1', require: false

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7', '>= 2.7.0'

# JSON API
gem 'jsonapi-rails'

gem 'jquery-rails', '>= 4.4.0'

# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'

# Use Puma as the app server
gem 'puma', '~> 5.6', '>= 5.6.4'

# Audit log
gem 'rails_event_store'

# Auth0
gem 'auth0', '~> 4.4', require: false

# Google Login
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection', '~> 1.0', '>= 1.0.0'

# Admin Frontend
gem 'haml-rails', '>= 2.0.1'
gem 'sass-rails', '~> 6.0', '>= 6.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'kaminari', '>= 1.2.2'
gem 'simple_form', '>= 5.1.0'

gem 'aws-sdk-cloudwatch', require: false
gem 'aws-sdk-s3', require: false
gem 'azure-storage-blob', '>= 2.0.3', require: false

# Exception tracking
gem 'rollbar'

# Logging
gem 'lograge', '>= 0.11.2'
gem 'skylight', '4.0.0'

gem 'rubocop'
gem 'rubocop-rails', '~> 2.10', '>= 2.10.1'

gem 'progress_bar', require: false

gem 'sidekiq-pro', source: 'https://gems.contribsys.com/'
gem 'sidekiq-cron', '>= 1.2.0'

gem 'activerecord-import'

gem 'parslet'

# For parsing and manipulating excel docs
gem 'rubyXL', '~> 3.4', '>= 3.4.25'

# SOAP-related libraries for Workday integration
gem 'lolsoap', '>= 0.10.0', require: false
gem 'akami', '>= 1.3.1', require: false
gem 'http', '>= 4.0.0'

# Used for FDL testing (see FDL::Validations::Test)
gem 'hashdiff', require: false

# Manually set Nokgiri version, to update version.
gem 'nokogiri', '>= 1.13.9'

group :development, :test do
  gem 'brakeman', require: false
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails', '>= 2.7.6'
  gem 'factory_bot_rails', '>= 6.2.0'
  gem 'pry-rails'
  gem 'rspec-rails', '>= 3.7.2'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.1'
  # Generate scaffold commands from schema.rb, instead of the other way around
  # gem 'schema_to_scaffold'
  # To spin up locally using postgis, (along with edits to database.yml)
  # gem 'activerecord-postgis-adapter'
end

group :test do
  gem 'database_cleaner'
  gem 'jsonapi-rspec', require: false
  gem 'ruby_event_store-rspec'
  gem 'rspec-json_expectations'
  gem 'shoulda-matchers', '~> 5.1'
  gem 'capybara', '>= 3.35.3'
  gem 'climate_control'
  gem 'webmock', '>= 3.4.2'
  gem 'launchy', '>= 2.4.3'
  gem 'simplecov', '~> 0.21.2'
end
