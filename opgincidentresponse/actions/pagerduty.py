import logging
import json
import pypd
from django.db import models
from datetime import datetime
from django.conf import settings

from opgincidentresponse.models import PagerDutySpecialist
from response.core.models import Incident
from response.slack.models import CommsChannel

logger = logging.getLogger(__name__)

pypd.api_key = settings.PAGERDUTY_API_KEY

def page_specialist(incident: Incident, specialist: PagerDutySpecialist, message: str):
    logger.debug(f"Handling `page_specialist` on Incident {incident.id}")

    key = "1"
    logger.debug(
        f"About to call PagerDuty's API: 'pypd.Incident.find(incident_key={key})`"
    )
    pd_incident = next(iter(pypd.Incident.find(incident_key=key)), None)
    logger.debug(
        f"Completed call to PagerDuty's API: 'pypd.Incident.find(incident_key={key})`"
    )

    comms_channel = CommsChannel.objects.get(incident=incident)
    message = f"{message}. Please join us in #{comms_channel.channel_name}"

    try:
        if pd_incident:
            logger.debug(
                f"Existing pagerduty incident found so reassigning to the specialists"
            )

            from_user = pypd.User.find_one(email=settings.PAGERDUTY_EMAIL)
            pd_incident.add_responders(
                settings.PAGERDUTY_EMAIL,
                from_user.id,
                message,
                escalation_policy_ids=[specialist.escalation_policy],
            )
        else:
            logger.debug(
                f"No existing pagerduty incident so triggering one directly for the specialists"
            )
            trigger_incident(
                message,
                key,
                incident.report or "",
                escalation_policy=specialist.escalation_policy,
            )
        comms_channel.post_in_channel(
            f"We've sent a page to {specialist.name} with the message: \n>{message}"
        )

    except Exception as e:
        logger.error(f"PagerDuty Error: {e}")
        comms_channel.post_in_channel(
            f"It looks like that didn't work. You can page them directly at https://moj-digital-tools.pagerduty.com"
        )

def trigger_incident(title, key, details=None, from_email=None, escalation_policy=None):
    data = {
        'type': 'incident',
        'title': title,
        'incident_key': key,
        'service': {
                'type': 'service_reference',
                'id': settings.PAGERDUTY_SERVICE,
        },
        'body': {
            'type': 'incident_body',
            'details': details or "",
        },
        'urgency': 'high',
    }

    if escalation_policy:
        data['escalation_policy'] = {
            "id": escalation_policy,
            "type": "escalation_policy_reference"
        }

    pypd.Incident.create(
        data=data,
        add_headers={'from': from_email or settings.PAGERDUTY_EMAIL}
    )