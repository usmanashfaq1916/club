from django.contrib import admin
from .models import User, Academy


@admin.register(Academy)
class AcademyAdmin(admin.ModelAdmin):
    list_display = ['name', 'location', 'created_at']
    search_fields = ['name', 'location']


admin.site.register(User)
