from response.core.models.incident import Incident
from django.conf import settings
from response.slack.models import CommsChannel
from response.slack.decorators import keyword_handler

@keyword_handler(['status page', 'statuspage'])
def status_page_notification(comms_channel: CommsChannel):
    comms_channel.post_in_channel(f"ℹ️ You mentioned the Status Page - You can find our statuspage here: https://theofficeofthepublicguardian.statuspage.io/")

@keyword_handler(['status page', 'statuspage'])
def runbook_notification(comms_channel: CommsChannel):
    comms_channel.post_in_channel(f"ℹ️ You mentioned runbooks - You can find runbooks for our services here: https://ministryofjustice.github.io/opg-technical-guidance/#opg-technical-guidance/")