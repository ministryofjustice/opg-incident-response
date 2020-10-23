import statuspageio

from django.conf import settings
from django.db import models

from response.core.models import Incident

class StatusPageError(Exception):
    pass

__statuspage_client = None

def statuspage_client():
    global __statuspage_client
    if __statuspage_client == None:
        if getattr(settings, "STATUSPAGEIO_API_KEY", None) and getattr(
            settings, "STATUSPAGEIO_PAGE_ID", None
        ):
            __statuspage_client = statuspageio.Client(
                api_key=settings.STATUSPAGEIO_API_KEY,
                page_id=settings.STATUSPAGEIO_PAGE_ID,
            )
        else:
            raise ValueError(
                "Statuspage client called but not configured. Check that STATUSPAGEIO_API_KEY and STATUSPAGEIO_PAGE_ID are configured in Django settings."
            )
    return __statuspage_client

class StatusPage(models.Model):
    incident = models.ForeignKey(Incident, on_delete=models.PROTECT)
    statuspage_incident_id = models.CharField(max_length=100, unique=True, null=True)

    def update_statuspage(self, **kwargs):
        if self.statuspage_incident_id:
            statuspage_client().incidents.update(
                incident_id=self.statuspage_incident_id, **kwargs
            )
        else:
            response = statuspage_client().incidents.create(**kwargs)
            self.statuspage_incident_id = response["id"]
            self.save()

    def get_from_statuspage(self):
        if self.statuspage_incident_id:
            for incident in statuspage_client().incidents.list():
                if incident["id"] == self.statuspage_incident_id:
                    return {
                        "name": incident["name"],
                        "status": incident["status"],
                        "message": incident["incident_updates"][0]["body"],
                        "impact_override": incident["impact_override"],
                    }
            raise StatusPageError(
                f"Statuspage incident with id {self.statuspage_incident_id} not found"
            )
        return {}
