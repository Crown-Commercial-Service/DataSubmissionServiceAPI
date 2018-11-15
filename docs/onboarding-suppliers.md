# Onboarding Suppliers and their users

Because of the dependency on Auth0 for authentication and the way the
architecture and data model is currently split, onboarding suppliers and their
users is a three-step process:

  1. Add suppliers
  2. Add users to Auth0 and local database, and create memberships

## 1. Add suppliers to the API application

See [this data migration](dbdata_migrate/20180927100810_seed_agreements_for_october_suppliers.rb)
for an example of a data migration that will add a list of new suppliers to
the application. Note that it also outputs a data-structure that will be used
in the next step.

## 2. Add users to Auth0 and local database, and create memberships

This can be performed using the `Auth0AuthenticatedUser` utility class.

Below is an example Ruby script demonstrating its use. It assumes the following:
- There is a CSV file containing the user details with headers: Supplier Name,
  User Name, Email
- All suppliers have already been created in step 1
- AUTH0 environment variables are set, including one called `AUTH0_API_TOKEN`
  that contains a valid API token. One can be acquired from "API Explorer" tab
  in the API section of Auth0.

```ruby
require 'auth0'
require 'csv'
 # set this based on the output from the supplier data migration that is run on the API
 auth0_client = Auth0Client.new(
  client_id: ENV['AUTH0_CLIENT_ID'],
  domain: ENV['AUTH0_DOMAIN'],
  token: ENV['AUTH0_API_TOKEN'], # This needs to be generated/acquired from Auth0
  api_version: 2
)
 # copy the csv to the docker container using docker cp. Make sure to cleanup after!
CSV.read('./tmp/users.csv', headers: true, header_converters: :symbol).each do |row|
  user_name = row.fetch(:user_name)
  email = row.fetch(:email)
  supplier_name = row.fetch(:supplier_name)
  supplier = Supplier.find_by!(name: supplier_name)
  user = if User.exists?(email: email)
    p "found #{email}"
    User.find_by(email: email)
  else
    sleep(0.5)
    p "created #{email}"
    auth0_authenticated_user = Auth0AuthenticatedUser.new(auth0_client, user_name, email, supplier_name, supplier.id)
    auth0_authenticated_user.create!
  end
  supplier.users << user unless supplier.users.include?(user)
  p "added #{email} to #{supplier_name}"
end
```
