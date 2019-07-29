# Data Submission Service API

Various parts of the system are documented in `/docs` and also as part of the
[Service Manual for the service](https://github.com/Crown-Commercial-Service/ReportMI-service-manual).

### Prerequisites

Use Homebrew to install Postgres, Redis, curl, Python and csvkit on MacOS:

`$ brew install postgres redis curl csvkit`

The application requires a user named `postgres` so create that user if it does not exist already:

`$ createuser postgres`

#### Auth0 Account

Liaise with the team members to get an account on Auth0. Once you have this, log into Auth0 and visit `Applications` to get the `AUTH0_CLIENT_ID` and `AUTH0_CLIENT_SECRET` values for the `.env` files (see next section)

#### Yarn

Install Yarn on MacOS with Homebrew:

`$ brew install yarn`

#### Bundler

Install Bundler:

`$ gem install bundler`

### Setting up the project

Copy `.env.development.example` to `.env.development`. This file contains some
secrets which need to be set. Liaise with team members to get the required
values. See [environment-variables.md](/docs/environment-variables.md) for a
description of all these environment variables.

Once this is done, use Bundler to set up the project:

`$ bundle install`

Create & set up the database:

`$ bundle exec rake db:setup`

Next, copy `.env.test.example` to `.env.test`. This file needs a `SECRET_KEY_BASE` parameter which you can generate with Rake:

`$ rake secret`

Install front-end dependencies:

`$ yarn install`

### Seeding the database

`db/seeds.rb` is out of date at the time of writing. Instead, ask the team for a dump of the live database.

Once you have the database dump, you can import it into your local Postgres with:

`$ pg_restore -h localhost -U postgres -d DataSubmissionServiceApi_development /path/to/database/dump.tar`

## Running the tests

To run the rspec tests:

`$ bundle exec rspec`

To run the full test suite - Rubocop, Brakeman and Rspec - before pushing to Github:

`$ bundle exec rake` (the default Rake task)

## Run the application

`$ bundle exec rails s`

The application will run on port 3000 by default.

### The admin interface

The admin interface is available at `/admin`. In production its use requires
OAuth authentication via a Google provider, but there is a `DeveloperAdmin` provider
which will let you log in locally to develop admin functions without credentials. You
should not need to do anything to set this up; it will apply by default if either of
`GOOGLE_CLIENT_ID` or `GOOGLE_CLIENT_SECRET` are missing from your development environment.

It will use the email address from `.env.development / ADMIN_EMAILS` by default with a
default user full name, either of which can be changed at login if you wish.

## API Endpoints

A [full list of the API endpoints](endpoints.md) is available in a separate document.

## Onboarding suppliers and users

See [this guide](docs/onboarding-suppliers.md) for details on onboarding suppliers
and their users.

## Running the sidekiq workers

If you want to be able to locally ingest files, or run any other
sidekiq jobs, then you need to run a sidekiq worker. You can do this by running `SIDEKIQ_CONCURRENCY=3 bundle exec sidekiq`.

## Scheduled jobs

Job scheduling is handled using the sidekiq-cron gem, with the schedule
defined in config/sidekiq_schedule.yml.

## Generating monthly tasks

The monthly tasks for suppliers are generated on the 1st of the month via the
sidekiq schedule described above.

## Reporting rake tasks

There are Rake tasks to report the status of monthly tasks:

```
  # Reports monthly task statistics. Defaults to the current month’s tasks.
  $ bundle exec rake report:submission_stats

  # Report spend and management charge. Defaults to the current month’s tasks.
  $ bundle exec rake report:spend_and_management_charge
```

## Console helpers

There are some handy methods available in the Rails console for debugging
submissions and reporting on the state of the monthly tasks. See
[lib/console_helpers.rb](lib/console_helpers.rb) for more details.
