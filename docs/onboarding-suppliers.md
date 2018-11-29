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

Below is an example Ruby script demonstrating its use. It assumes the following:
- There is a CSV file containing the user details with headers: Supplier Name,
  User Name, Email
- All suppliers have already been created in step 1

```ruby
require 'csv'
 # copy the csv to the docker container using docker cp. Make sure to cleanup after!
CSV.read('./tmp/users.csv', headers: true, header_converters: :symbol).each do |row|
  user_name = row.fetch(:user_name)
  email = row.fetch(:email)
  supplier_name = row.fetch(:supplier_name)
  supplier = Supplier.find_by!(name: supplier_name)
  if User.exists?(email: email)
    p "found #{email}"
    user = User.find_by(email: email)
  else
    sleep(0.5)
    p "created #{email}"
    user = User.create!(name: user_name, email: email)
    user.create_with_auth0
  end
  supplier.users << user unless supplier.users.include?(user)
  p "added #{email} to #{supplier_name}"
end
```
