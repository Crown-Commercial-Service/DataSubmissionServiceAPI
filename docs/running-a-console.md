# Running a console on staging/prod

The full infrastructure documentation is in the [Service Manual](https://crown-commercial-service.github.io/ReportMI-service-manual/#/infrastructure), however these are some quick useful commands for running a Rails console on GPaas/Cloud Foundry.

---

This application is hosted on GPaas ([GOV.UK Platform as a Service](https://docs.cloud.service.gov.uk/)). In order to run a console on staging or production you will first need a GPaas login. Contact the RMI team or your delivery lead for help.

Once you have your GPaas login, follow the instructions to [download Cloud Foundry](https://docs.cloud.service.gov.uk/get_started.html) and log in with your new credentials.

## Useful commands

### See which spaces are available

```bash
cf spaces
```

### Switch between spaces

For prod

```bash
cf target -s prod
```

For staging

```bash
cf target -s staging
```

(etc)

### See which apps are running on your target workspace

```bash
cf apps
```

### Run a Rails console

```bash
cf v3-ssh <app from list of apps retrieved above>
/tmp/lifecycle/shell
cd app
rails c
```
