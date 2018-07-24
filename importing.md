# Import Users / Suppliers

Users and suppliers are imported from a CSV which MUST have the following
fields:

 - personname (full name of user)
 - email
 - suppliername
 - frameworkreference (the framework's RM number)

Also, the file needs to encoded in UTF-8 or you'll get errors! To convert an
existing file, run the following on the command line:

`iconv -c -f "US-ASCII" -t "UTF-8" input.csv > output.csv`

The following commands can be run from the Rails console, given a `csv`
variable that contains the contents of a CSV as a string.

# Importing suppliers

Running `require 'supplier_import'; SupplierImport.new(csv).run!` will:

 - Create any suppliers that don't already exist in the database
 - Assign these suppliers to the correct frameworks (NB: these should already
     exist)

# Importing users

First, you'll need to obtain the Auth0 client_id, token and domain. Then you'll
need to set the `csv` variable as above.

Once you have these, run the following from the Rails console.

```ruby
client = Auth0Client.new(client_id: client_id, token: token, domain: domain)
UserImport.new(csv, client).run!
```

You'll see an output like this (one for every row in the CSV)

```
auth0:1234566788,email@example.com,password,John Smith
```

**Make a note of this, as it's the only place where you can see the passwords
generated for each user.**


