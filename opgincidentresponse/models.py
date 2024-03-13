from django.contrib import admin
from django.db import models

class PagerDutySpecialist(models.Model):
    name = models.CharField(max_length=100, unique=True)
    summary = models.TextField(max_length=1000)
    escalation_policy = models.CharField(max_length=10)

    def __str__(self):
        return f"{self.name} - {self.escalation_policy}"


@admin.register(PagerDutySpecialist)
class PagerDutySpecialistAdmin(admin.ModelAdmin):
    pass
