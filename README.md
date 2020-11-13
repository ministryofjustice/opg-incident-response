# OPG Incident Response ⚡

---

# Find out more

Response is a Django app which you can include in your project. Check out the [orginal repository](https://github.com/monzo/response) for instuctions.

---

# Local Development

## Environment variables

Copy `env.dev.example` to `.env` to configure environment variables. All environment variables need to be set, but some can set to blank values (i.e. `ENV_VAR=`) as detailed below.

| Variable                     | Value required?                | Details                                                                                             |
| ---------------------------- | ------------------------------ | --------------------------------------------------------------------------------------------------- |
| SECRET_KEY                   | Yes                            | Used by Django, can be set to anything                                                              |
| DJANGO_SETTINGS_MODULE       | Yes                            | Specifies which settings to use. Should be `opgincidentresponse.settings.dev` in local environments |
| SOCIAL_AUTH_\*               | Only if testing authentication | There's already a dev/localhost and production GitHub app you can use                               |
| SLACK_TOKEN                  | Yes                            | Provided when you create a Slack app                                                                |
| SLACK_SIGNING_SECRET         | Yes                            | Provided when you create a Slack app                                                                |
| SLACK_TEAM_ID                | Yes                            | You should test in a private team, not MOJD&T                                                       |
| INCIDENT_BOT_ID              | Yes                            | The ID of your test app                                                                             |
| INCIDENT_BOT_NAME            | Yes                            | The name of your test app                                                                           |
| INCIDENT_CHANNEL_NAME        | Yes                            | The channel to post new live incidents to                                                           |
| INCIDENT_REPORT_CHANNEL_NAME | Yes                            | The channel to post new incident reports to                                                         |
| STATUSPAGEIO_API_KEY         | Only if testing Statuspage     | Provided by Statuspage                                                                              |
| STATUSPAGEIO_PAGE_ID         | Only if testing Statuspage     | Provided by Statuspage                                                                              |
| PAGERDUTY_API_KEY            | Only if testing PagerDuty      | Provided by Pagerduty                                                                               |
| PAGERDUTY_EMAIL              | Only if testing PagerDuty      | Provided by Pagerduty                                                                               |
| PAGERDUTY_SERVICE            | Only if testing PagerDuty      | Provided by Pagerduty                                                                               |
