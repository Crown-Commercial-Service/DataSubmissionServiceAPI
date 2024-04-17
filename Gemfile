source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.1', '>= 7.1.3.1'

# State machine
gem 'aasm'

gem 'bootsnap', '~> 1.11', '>= 1.11.1', require: false

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7', '>= 2.7.0'
gem 'jbuilder', '~> 2.11', '>= 2.11.1'

# JSON API
gem 'jsonapi-rails'

gem 'jquery-rails', '>= 4.5.0'

gem 'jwt', '~> 2.2'

# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'

# Use Puma as the app server
gem 'puma', '~> 6.4', '>= 6.4.2'

# Audit log
gem 'rails_event_store', '~> 2.13', '>= 2.13.0'

# Markdown parser
gem 'redcarpet', '~> 3.6'

# Auth0
gem 'auth0', '~> 5.1', '>= 5.1.2', require: false

# Google Login
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection', '~> 1.0', '>= 1.0.1'

# Admin Frontend
gem 'haml-rails', '>= 2.1.0'
gem 'sass-rails', '~> 6.0', '>= 6.0.0'
gem 'uglifier', '~> 4.2'
gem 'kaminari', '>= 1.2.2'
gem 'simple_form', '>= 5.3.0'

gem 'aws-sdk-cloudwatch', require: false
gem 'aws-sdk-s3', require: false
gem 'azure-storage-blob', '>= 2.0.3', require: false

# Exception tracking
gem 'rollbar'

# Logging
gem 'lograge', '>= 0.14.0'
# gem 'skylight', '~> 6.0', '>= 6.0.0'

gem 'rubocop'
gem 'rubocop-rails', '~> 2.21', '>= 2.21.0'

gem 'progress_bar', require: false

gem 'sidekiq-pro', source: 'https://gems.contribsys.com/'
# gem 'sidekiq', '>=5.2.10' # Free version, use for local image building
gem 'sidekiq-cron', '>= 1.11.0'

# Alpine and Windows do not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby ruby]

gem 'activerecord-import', '>= 1.5.0'

gem 'parslet'

# To enable app maintenance mode
gem 'rack-maintenance', '~> 3.0'

# For parsing and manipulating excel docs
gem 'rubyXL', '~> 3.4', '>= 3.4.25'

# SOAP-related libraries for Workday integration
gem 'lolsoap', '>= 0.11.0', require: false
gem 'akami', '>= 1.3.2', require: false
gem 'http', '>= 4.0.0'

# Used for FDL testing (see FDL::Validations::Test)
gem 'hashdiff', require: false

# Manually set Nokgiri version, to update version.
gem 'nokogiri', '>= 1.16.2'

# Fix for already initialized constant warning, see: https://stackoverflow.com/questions/67773514/getting-warning-already-initialized-constant-on-assets-precompile-at-the-time
gem 'net-http', '>= 0.4.0'

gem 'sprockets-rails'

group :development, :test do
  gem 'brakeman', require: false
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails', '>= 3.0.0'
  gem 'factory_bot_rails', '~> 6.4', '>= 6.4.2'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 6.0', '>= 6.0.4'
end

group :development do
  gem 'listen', '~> 3.5', '>= 3.5.1'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 4.0'
  gem 'spring-watcher-listen', '~> 2.1'
  # Generate scaffold commands from schema.rb, instead of the other way around
  # gem 'schema_to_scaffold'
  # To spin up locally using postgis, (along with edits to database.yml)
  # gem 'activerecord-postgis-adapter'
end

group :test do
  gem 'database_cleaner', '~> 2.0', '>= 2.0.2'
  gem 'jsonapi-rspec', require: false
  gem 'ruby_event_store-rspec'
  gem 'rspec-json_expectations'
  gem 'shoulda-matchers', '~> 5.1', '>= 5.1.0'
  gem 'capybara', '~> 3.40', '>= 3.40.0'
  gem 'climate_control'
  gem 'webmock', '>= 3.4.2'
  gem 'launchy', '>= 2.4.3'
  gem 'simplecov', '~> 0.21.2'
end
