from opgincidentresponse.actions.pagerduty import page_specialist
from opgincidentresponse.actions.keyword_handlers import status_page_notification 
from response.slack.models import CommsChannel

def test_status_page_notification(mocker):
    mocker.patch.object(CommsChannel, 'post_in_channel')
    
    status_page_notification(CommsChannel, '', '', '', '')

    CommsChannel.post_in_channel.assert_called_once_with("ℹ️ You mentioned the Status Page - You can find our statuspage here: https://theofficeofthepublicguardian.statuspage.io/")
