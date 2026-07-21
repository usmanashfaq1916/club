from django.contrib import admin
from .models import Fee


@admin.register(Fee)
class FeeAdmin(admin.ModelAdmin):
    list_display = ['student', 'month', 'status', 'paid_amount', 'due_date']
    list_filter = ['status', 'month']
