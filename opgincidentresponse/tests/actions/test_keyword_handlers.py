from opgincidentresponse.actions.keyword_handlers import runbook_notification
from response.slack.models import CommsChannel

def test_runbook_notification(mocker):
    mocker.patch.object(CommsChannel, 'post_in_channel')
    
    runbook_notification(CommsChannel, '', '', '', '')

    CommsChannel.post_in_channel.assert_called_once_with("ℹ️ You mentioned runbooks - You can find runbooks for our services here: https://ministryofjustice.github.io/opg-technical-guidance/#opg-technical-guidance/")