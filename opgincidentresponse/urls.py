from django.contrib import admin
from django.contrib.auth.decorators import login_required
from django.urls import include, path
from django.urls import re_path
from health_check.views import HealthCheckView

from decorator_include import decorator_include

from . import views

urlpatterns = [
    path("", views.home, name="home"),
    path("login/", views.login, name="login"),
    path("incident/<int:incident_id>/", views.incident, name="incident_doc"),
    re_path("", include('social_django.urls', namespace='social')),
    path("admin/", admin.site.urls),
    path("slack/", include("response.slack.urls")),
    path("core/", decorator_include(login_required, "response.core.urls")),
    path(
        "ht/",
        HealthCheckView.as_view(
            checks=[
                "health_check.Database",
            ]
        ),
        name="health_check",
    )

]
