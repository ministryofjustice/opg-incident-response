from justhtml import JustHTML
from rest_framework.pagination import PageNumberPagination


def sanitize(string):
    return JustHTML(
        string,
        fragment=True
    ).to_html()


class LargeResultsSetPagination(PageNumberPagination):
    page_size = 500
    max_page_size = 1000
    page_size_query_param = "page_size"
