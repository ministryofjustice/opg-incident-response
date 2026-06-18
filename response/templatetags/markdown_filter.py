import bleach
import markdown2
from bleach.css_sanitizer import CSSSanitizer
from django import template
from django.conf import settings

register = template.Library()


@register.filter
def markdown_filter(text):
    text = markdown2.markdown(text)

    css_sanitizer = CSSSanitizer(allowed_css_properties=settings.MARKDOWN_FILTER_WHITELIST_STYLES)

    html = bleach.clean(
        text,
        tags=settings.MARKDOWN_FILTER_WHITELIST_TAGS,
        attributes=settings.MARKDOWN_FILTER_WHITELIST_ATTRIBUTES,
        css_sanitizer=css_sanitizer,
    )
    return bleach.linkify(html)
