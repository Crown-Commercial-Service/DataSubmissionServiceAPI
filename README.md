# Data Submission Service API

An API layer that manages and exposes data on CCS frameworks. This service ingests submissions and create invoices for business done each month against each active framework.

Admin users are able to use this tool to create new users and associate them with suppliers. These users will then be able to use [the frontend application](https://github.com/dxw/DataSubmissionServiceAPI) to submit their information.

Various parts of the system are documented in `/docs` and also as part of the
[Service Manual for the service](https://github.com/Crown-Commercial-Service/ReportMI-service-manual).

---

### Prerequisites

- [Docker](https://docs.docker.com/docker-for-mac) greater than or equal to `18.03.1-ce-mac64 (24245)`
- Access to the dxw 1Password vault named `DSS` can be granted by anyone on the dxw technical operations team

### Setting up the project

Copy the example environment variable file used with Docker:

```bash
$ cp docker-compose.env.sample docker-compose.env
```

From the 1Password vault, copy the contents of a file named `Docker Compose - API - docker-compose.env` into the new `docker-compose.env` file. This file should contain no further additions to get started.

The most common command used to start all containers. It does database set up if required and leaves you on an interactive prompt within the rails server process where `pry` can be used for debugging:

```bash
$ bin/dstart
```

If you'd like to see all logs, like `Sidekiq` or `Redis` you can use the conventional docker-compose command - you will lose the ability to use `pry`:

```bash
$ docker-compose up
```

If you'd like to shut all containers down, and remove database information persisted in `docker volumes` you can run the following command which rebuilds everything from scratch:

```bash
$ bin/drebuild
```

---

## Running the tests

Because the setup and teardown introduces quite some latency, we use the spring service to
start up all dependencies in a docker container. This makes the test run faster.

Get the test server up and running behind the scenes:

```bash
$ bin/dtest-server up
```

Run all the RSpec tests:

```bash
$ bin/dspec spec
```

When no arguments are specified, the default rake task is executed. This runs other tests such as `Rubocop` for linting and `brakeman` for static code analysis.

You can use pass arguments as you normally would to RSpec through this script, to run a single test for example you can use `bin/dspec spec/features/adding_a_user_spec.rb:1`

To stop the test server from running in the background:

```bash
$ bin/dtest-server down
```

---

## Managing gems

When making changes to the Gemfile we should use Docker too in order to ensure we use a consistent version of Bundler:

```bash
$ docker-compose run --rm web bundle
```

The Bundler version in the Gemfile.lock should remain unchanged unless part of a deliberate update.

```
BUNDLED WITH
  2.0.1
```

---

## The admin interface

The admin interface is available at `/admin`. In production its use requires
OAuth authentication via a Google provider, but there is a `DeveloperAdmin` provider
which will let you log in locally to develop admin functions without credentials. You
should not need to do anything to set this up; it will apply by default if either of
`GOOGLE_CLIENT_ID` or `GOOGLE_CLIENT_SECRET` are missing from your development environment.

It will use the `ADMIN_EMAILS` variable from `docker-compose.env` by default with a
default user full name, either of which can be changed at login if you wish.

## API Endpoints

A [full list of the API endpoints](endpoints.md) is available in a separate document.

## Onboarding suppliers and users

See [this guide](docs/onboarding-suppliers.md) for details on onboarding suppliers
and their users.

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
  $ bin/drake report:submission_stats

  # Report spend and management charge. Defaults to the current month’s tasks.
  $ bin/drake report:spend_and_management_charge
```

## Console helpers

There are some handy methods available in the Rails console for debugging
submissions and reporting on the state of the monthly tasks. See
[lib/console_helpers.rb](lib/console_helpers.rb) for more details.


## Deployments

Documentation on how deployments are managed for the RMI service as a whole are documented within the [service manual](https://crown-commercial-service.github.io/ReportMI-service-manual/#/deployments).
