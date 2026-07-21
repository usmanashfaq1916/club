from django.db import models
from students.models import Student


class Fee(models.Model):
    STATUS_CHOICES = [
        ('Paid', 'Paid'),
        ('Partial', 'Partial'),
        ('Pending', 'Pending'),
    ]
    METHOD_CHOICES = [
        ('Cash', 'Cash'),
        ('UPI', 'UPI'),
        ('Bank Transfer', 'Bank Transfer'),
        ('Card', 'Card'),
    ]

    student = models.ForeignKey(
        Student, on_delete=models.CASCADE, related_name='fee_records'
    )
    month = models.CharField(max_length=20)
    monthly_fee = models.DecimalField(max_digits=10, decimal_places=2)
    discount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    paid_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    balance = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    due_date = models.DateField()
    payment_date = models.DateField(null=True, blank=True)
    payment_method = models.CharField(max_length=20, choices=METHOD_CHOICES, blank=True)
    receipt_number = models.CharField(max_length=50, blank=True)
    status = models.CharField(
        max_length=10, choices=STATUS_CHOICES, default='Pending'
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-due_date']

    def __str__(self):
        return f'{self.student.full_name} - {self.month}'
