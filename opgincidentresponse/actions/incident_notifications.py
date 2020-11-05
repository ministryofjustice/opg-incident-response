from response.core.models import Incident
from response.slack.models import CommsChannel
from response.slack.decorators import recurring_notification, single_notification


@single_notification()
def incident_response_process(incident: Incident):
    comms_channel = CommsChannel.objects.get(incident=incident)
    comms_channel.post_in_channel("📗 You can find our Incident Response process here https://ministryofjustice.github.io/opg-technical-guidance/incidents/incident-response-process/#incident-response-process")

@recurring_notification(interval_mins=30, max_notifications=10)
def take_a_break(incident: Incident):
    comms_channel = CommsChannel.objects.get(incident=incident)
    comms_channel.post_in_channel("👋 30 minutes have elapsed. Think about taking a few minutes away from the screen.")
