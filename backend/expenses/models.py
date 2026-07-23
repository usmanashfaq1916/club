from django.db import models
from django.conf import settings


class Expense(models.Model):
    CATEGORY_CHOICES = [
        ('Equipment', 'Equipment'),
        ('Maintenance', 'Maintenance'),
        ('Salary', 'Salary'),
        ('Utilities', 'Utilities'),
        ('Tournament', 'Tournament'),
        ('Transport', 'Transport'),
        ('Medical', 'Medical'),
        ('Other', 'Other'),
    ]
    title = models.CharField(max_length=200)
    category = models.CharField(max_length=30, choices=CATEGORY_CHOICES)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    date = models.DateField()
    notes = models.TextField(blank=True)
    status = models.CharField(
        max_length=20,
        choices=[('Pending', 'Pending'), ('Approved', 'Approved'), ('Rejected', 'Rejected')],
        default='Pending',
    )
    reviewed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True,
        related_name='reviewed_expenses'
    )
    academy = models.ForeignKey(
        'accounts.Academy', on_delete=models.SET_NULL, null=True, blank=True,
        related_name='expenses'
    )
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-date']

    def __str__(self):
        return f'{self.title} - {self.amount}'
