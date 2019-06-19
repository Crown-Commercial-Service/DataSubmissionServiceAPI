# Fetching the JWT public key from Auth0

The `AUTH0_JWT_PUBLIC_KEY` needs to be set in your local environment in order to
validate requests against the Auth0 key pair. You can fetch this from the Auth0
admin UI (https://manage.auth0.com/)

  1. Go to 'Applications' and click on the relevant application from the list
  2. Scroll down to the bottom of the page, and click 'Show Advanced Settings'
  3. Click on 'Certificates'
  4. Copy the 'Signing Certificate' to your clipboard
  5. In a Rails console, set the `cert` variable to the contents of your
     clipboard
  6. Run `OpenSSL::X509::Certificate.new(cert).public_key.to_s` to show your
     public key
  7. Copy this into your `.env` file, as `AUTH0_JWT_PUBLIC_KEY`
