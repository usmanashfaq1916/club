from django.db import models


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
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-date']

    def __str__(self):
        return f'{self.title} - {self.amount}'
