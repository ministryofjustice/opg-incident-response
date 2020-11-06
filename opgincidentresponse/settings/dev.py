import os

from .base import *  # noqa: F401, F403
from .base import SLACK_CLIENT, get_env_var

SITE_URL = "http://localhost:8000"

if os.environ.get("POSTGRES"):
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.postgresql",
            "HOST": os.getenv("DB_HOST", "db"),
            "PORT": os.getenv("DB_PORT", "5432"),
            "USER": os.getenv("DB_USER", "postgres"),
            "NAME": os.getenv("DB_NAME", "postgres"),
        }
    }


LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "simple": {
            "format": " {levelname:5s} - {module:10.15s} - {message}",
            "style": "{",
        }
    },
    "handlers": {
        "console": {
            "level": "INFO",
            "class": "logging.StreamHandler",
            "formatter": "simple",
        }
    },
    "loggers": {
        "": {
            "handlers": ["console"],
            "level": os.getenv("DJANGO_LOG_LEVEL", "INFO"),
            "propagate": False,
        }
    },
}

RESPONSE_LOGIN_REQUIRED = False

SLACK_TOKEN = get_env_var("SLACK_TOKEN")
SLACK_SIGNING_SECRET = get_env_var("SLACK_SIGNING_SECRET")
SLACK_TEAM_ID = get_env_var("SLACK_TEAM_ID")
INCIDENT_CHANNEL_NAME = get_env_var("INCIDENT_CHANNEL_NAME")
INCIDENT_REPORT_CHANNEL_NAME = get_env_var("INCIDENT_REPORT_CHANNEL_NAME")
INCIDENT_BOT_NAME = get_env_var("INCIDENT_BOT_NAME")

SLACK_API_MOCK = os.getenv("SLACK_API_MOCK", None)

INCIDENT_BOT_ID = os.getenv("INCIDENT_BOT_ID") or SLACK_CLIENT.get_user_id(
    INCIDENT_BOT_NAME
)
INCIDENT_CHANNEL_ID = os.getenv("INCIDENT_CHANNEL_ID") or SLACK_CLIENT.get_channel_id(
    INCIDENT_CHANNEL_NAME
)
INCIDENT_REPORT_CHANNEL_ID = os.getenv(
    "INCIDENT_REPORT_CHANNEL_ID"
) or SLACK_CLIENT.get_channel_id(INCIDENT_REPORT_CHANNEL_NAME)

STATUSPAGEIO_API_KEY = get_env_var("STATUSPAGEIO_API_KEY")
STATUSPAGEIO_PAGE_ID = get_env_var("STATUSPAGEIO_PAGE_ID")
PAGERDUTY_API_KEY = get_env_var("PAGERDUTY_API_KEY")
PAGERDUTY_SERVICE = get_env_var("PAGERDUTY_SERVICE")
PAGERDUTY_EMAIL = get_env_var("PAGERDUTY_EMAIL")