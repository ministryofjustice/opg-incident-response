import re

from django import template
from response.core.models import ExternalUser

register = template.Library()

@register.filter
def slack_format(value):
    if type(value) is not str:
        return value

    user_links = re.findall(r"&lt;@(U.+?)&gt;", value)

    for user_id in user_links:
        user = ExternalUser.objects.get(external_id=user_id)

        value = value.replace('&lt;@' + user_id + '&gt;', '<a class="govuk-link" href="slack://user?team=T02DYEB3A&amp;id=' + user.external_id + '">' + user.full_name + '</a>')

    links = re.findall(r"<(https?://.+?)(?:\|(.+?))?>", value)

    for (link, label) in links:
        match = (link + '|' + label) if label else link
        value = value.replace('<' + match + '>', '<a class="govuk-link" href="' + link + '">' + (label if label else link) + '</a>')

    return value.replace('\n', '<br />')
