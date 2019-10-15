# https://dxw.zendesk.com/agent/tickets/10226
#
# The problem:
# A Customer was created in the production db with a URN of 0. Submission Entries were then uploaded to RMI
# with non-numeric Customer URNs. These URNs were coerced into 0 and the submission entries were associated with
# the Customer.
# These entries should have been rejected for non-existent URNs but they were not.
#
# The intial solution:
# db/data_migrate/201910101570722493_correct_bad_customer_urns.rb was created to fix the "bad" URNs in both
# submission_entry.customer_urn and also the Customer URN in the data JSON field. However, due to poor db performance,
# the script did not execute fully and
# as a result there were still submission entries with a customer_urn of 0. Worse, not all data fields contained a
# "Customer URN" key, because in some JSON blobs the Customer URN is referred to as
# "Customer Unique Reference Number (URN)" or similar.
#
# This solution:
# After a lot of discussion we have decided to patch up this problem with SQL. As we can no longer easily find the
# "actual" URN for submission entries with a customer_urn of 0, we have decided to:
# 1) Set the customer_urn for any entry with a customer_urn of 0 to 33333333
# 2) Delete the Customer with a URN of 0 from the database
#
# This way, when someone uploads a submission entry with a non-numeric customer URN, they will be rightly rejected,
# as that URN will be coerced to 0 and there is no Customer with a URN of 0.
#
# Run with:
# rails runner db/data_migrate/201910151571144147_update_submission_entries_with_0_customer_urn.rb
ActiveRecord::Base.connection.execute(
  <<~POSTGRESQL
    UPDATE submission_entries
    SET customer_urn = 33333333 WHERE customer_urn = 0;
    DELETE FROM customers WHERE urn = 0;
POSTGRESQL
)
