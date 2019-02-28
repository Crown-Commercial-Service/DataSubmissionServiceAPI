# Importing updated customers from the URN list

Import any new customers that have been added since the last URN list update

You'll need:

 - Recent production database cut
 - The latest URN list provided by CCS, converted to CSV

Firstly, copy the URN CSV file into `db/data_migrate/` on your local
development environment and rename it to `new-big-customer.csv`.

Next, run the filter customers script:
`rails runner db/data_migrate/filter_customers.rb`

This will generate a new file `import.csv` which will include ONLY new
customers.

Copy this file to `db/data_migrate/YYYYMMDDHHMMSS_import_MONTH_customers.csv`.

Now copy the most recent customer data migration to
`db/data_migrate/YYYYMMDDHHMMSS_import_MONTH_customers.rb` and update:
 - Instructions in the comment
 - The filename of the CSV

Run `rails runner db/data_migrate/YOUR_MIGRATION_SCRIPT.rb` to check that it
imports correctly.

Commit the changes and open a PR.
