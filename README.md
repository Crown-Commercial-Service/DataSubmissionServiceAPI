# Data Submission Service API

### Prerequisites
 - [Docker](https://docs.docker.com/docker-for-mac) greater than or equal to `18.03.1-ce-mac64 (24245)`

### Setting up the project

Copy the docker environment variables and fill in any missing secrets:

```
$ cp docker-compose.env.sample docker-compose.env
```

Build the docker container and set up the database

`bin/drebuild`

Start the application

`bin/dstart`

## Running the tests

There are two ways that you can run the tests.

### In development

Because the setup and teardown introduces quite some latency, we use the spring service to
start up all dependencies in a docker container. This makes the test run faster.

Get the test server up and running
`bin/dtest-server`

Run the specs. When no arguments are specified, the default rake task is executed.
`bin/dspec <args>`

### Full run (before you push to github)

Rebuilds the test server, runs rubocop checks, runs the test suite and cleans up.

`bin/dtests`

## API Endpoints

A [full list of the API endpoints](endpoints.md) is available in a separate document.

## Onboarding suppliers and users

See [this guide](docs/onboarding-suppliers.md) for details on onboarding suppliers
and their users.

## Generating monthly tasks

Monthly tasks are be generated manually using the following rake task:

```
  # Generates tasks based on existing agreements for September 2018
  $ rake generate:tasks[9,2018]
```

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
