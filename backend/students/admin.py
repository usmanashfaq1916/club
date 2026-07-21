from django.contrib import admin
from .models import Student


@admin.register(Student)
class StudentAdmin(admin.ModelAdmin):
    list_display = ['full_name', 'batch', 'skill_level', 'mobile_number', 'is_active']
    list_filter = ['batch', 'skill_level', 'is_active']
    search_fields = ['full_name', 'mobile_number']
