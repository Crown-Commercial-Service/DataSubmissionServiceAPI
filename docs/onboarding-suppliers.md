# Onboarding Suppliers and their users

Because of the dependency on Auth0 for authentication and the way the
architecture and data model is currently split, onboarding suppliers and their
users is a three-step process:

  1. Add suppliers to the API application using a data migration
  2. Add users to the supplier-facing application and Auth0
  3. Link the users to their suppliers in the API application

## 1. Add suppliers to the API application

See [this data migration](dbdata_migrate/20180927100810_seed_agreements_for_october_suppliers.rb)
for an example of a data migration that will add a list of new suppliers to
the application. Note that it also outputs a data-structure that will be used
in the next step.

## 2. Add users to the supplier-facing application and Auth0

The next step is documented in the DataSubmissionService repo in
docs/setting-up-new-users.md. Essentially some utility code can be used to
1) add the users to Auth0; 2) Add user records to the application database; 3)
output the code that will complete the next step.

## 3. Link the users to their suppliers in the API application

The output from the previous step will need to be run on the API application
so that the newly added users are associated with their suppliers.
