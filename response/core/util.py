import bleach
import bleach_allowlist
from django.conf import settings
from rest_framework.pagination import PageNumberPagination


def sanitize(string):
    # bleach doesn't handle None so let's not pass it
    if string and getattr(settings, "RESPONSE_SANITIZE_USER_INPUT", True):
        return bleach.clean(
            string,
            tags=bleach_allowlist.markdown_tags,
            attributes=bleach_allowlist.markdown_attrs,
            styles=bleach_allowlist.all_styles,
        )

    return string


class LargeResultsSetPagination(PageNumberPagination):
    page_size = 500
    max_page_size = 1000
    page_size_query_param = "page_size"
