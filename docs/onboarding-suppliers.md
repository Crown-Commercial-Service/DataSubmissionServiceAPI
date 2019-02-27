# Onboarding Suppliers and their users

Because of the dependency on Auth0 for authentication and the way the
architecture and data model is currently split, onboarding suppliers and their
users is a three-step process:

  1. Add suppliers
  2. Add users to Auth0 and local database, and create memberships

## 1. Add suppliers to the API application

See [this data migration](db/data_migrate/20190227162046_add_rm6060_suppliers.rb)
for an example of a data migration that will add a list of new suppliers to
the application. Note that it also outputs a data-structure that will be used
in the next step.

## 2. Add users to Auth0 and local database, and create memberships

The [`Import::Users`](app/models/import/users.rb) utility class can be used to
bulk-import users:

```ruby
Import::User.new('/tmp/users.csv').run
```

See the class file for further documentation.
