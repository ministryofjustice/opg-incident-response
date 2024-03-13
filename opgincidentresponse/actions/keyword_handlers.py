from response.slack.models import CommsChannel
from response.slack.decorators import keyword_handler

@keyword_handler(['runbook', 'run book'])
def runbook_notification(comms_channel: CommsChannel, user: str, keyword: str, text: str, ts: str):
    comms_channel.post_in_channel(f"ℹ️ You mentioned runbooks - You can find runbooks for our services here: https://ministryofjustice.github.io/opg-technical-guidance/#opg-technical-guidance/")