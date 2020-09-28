from django.contrib import admin
from django.urls import include, path
from django.conf.urls import url

urlpatterns = [
    path("", include("response.ui.urls")),
    path('accounts/', include('allauth.urls')),
    path("admin/", admin.site.urls),
    url(r'^ht/', include('health_check.urls')),
    path("slack/", include("response.slack.urls")),
    path("core/", include("response.core.urls")),
]