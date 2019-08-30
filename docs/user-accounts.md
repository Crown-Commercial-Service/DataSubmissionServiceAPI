# User accounts

ReportMI consists of two services that are used by two distinct sets of users:

- The admin app (hereafter RMI Admin), which is the service contained in this
  repository. This is used by Crown Commercial Service (CCS) staff to manage
  users, suppliers, and process returns. It also provides an API that's consumed
  by the frontend.

- The frontend (hereafter RMI Frontend), which is used by external suppliers to
  submit their returns to CCS.

In production, CCS staff log into RMI Admin using their Google account. They use
RMI Admin to manage logins for external suppliers, which are stored in Auth0.
Suppliers log into RMI Frontend, which talks to the RMI Admin API and to Auth0.

          +--------------------+        +-------------------+
          |     Google SSO     |        |       Auth0       |
          | (RMI Admin logins) |        | (Supplier logins) |
          +--------------------+        +-------------------+
                      ^                       ^     ^
                      |                       |     |
                      |     +-----------------+     |
                      |     |                       |
                  +-----------+               +--------------+
                  | RMI Admin |<--------------| RMI Frontend |
                  +-----------+               +--------------+
                        ^                             ^
                        |                             |
                    CCS staff                     Suppliers


## RMI Admin

In production, CCS staff log into RMI Admin using their Google SSO credentials.
The set of users that are allowed access to the app is stored in the environment
variable `ADMIN_EMAILS`.

In development, the environment variable `ADMIN_EMAILS` is still used but no
authentication is required. Just add your email address to `ADMIN_EMAILS` in
`docker-compose.env` before starting the app, and you will be able to log in
using that address.


## RMI Frontend

This is the app used by external suppliers to submit their returns. Logins to
this service are authorized by the RMI Admin API, and supplier login details are
stored in Auth0.

Both RMI Admin and Frontend require credentials for connecting to Auth0's API.
These credentials are stored in the `AUTH0_DOMAIN`, `AUTH0_CLIENT_ID` and
`AUTH0_CLIENT_SECRET` environment variables (kept in `docker-compose.yml` in
development). You'll need to get the right credentials for each app for the
environment you're running in:

- In development, we use the [dxw][1] tenant. It contains the following
  applications:
  - `Report MI Admin (Staging)`: corresponds to RMI Admin
  - `Report MI (Staging)`: corresponds to RMI Frontend

- In production, we use the [reportmi][2] tenant. It contains the following
  applications:
  - `Report MI Admin`
  - `Report MI`

To work with these services, you will need an admin login for Auth0, and access
to at least the `dxw` tenant.

So, to log into RMI Frontend in development:

- Make sure your email is stored under [Users][3] in the `dxw` tenant
- Make sure your details and Auth0 ID are stored in RMI Admin

If your details are missing from either environment, you should be able to use
the [Users section][4] of RMI Admin to add yourself. If your account already
exists in dxw's Auth0 tenant, that should not be a problem. However, if you run
into trouble using this method, here's what to do:

- Find your user record in [Auth0][3]
- Copy the `user_id` from your user profile; it should consist of the string
  `auth0|` followed by some random hex digits
- Open a rails console and create a user for yourself:

      ./bin/drails console
      > User.create auth_id: 'auth0|...', name: 'Delia Veloper', email: 'delia@dxw.com'

Once you've done this, you should be able to log into RMI Frontend using your
email address and the password stored in Auth0.

[1]: https://manage.auth0.com/dashboard/eu/dxw/
[2]: https://manage.auth0.com/dashboard/eu/reportmi/
[3]: https://manage.auth0.com/dashboard/eu/dxw/users
[4]: http://localhost:3000/admin/users
