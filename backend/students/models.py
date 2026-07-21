from django.db import models
from django.conf import settings


class Student(models.Model):
    BATCH_CHOICES = [('Morning', 'Morning'), ('Evening', 'Evening')]
    SKILL_CHOICES = [
        ('Beginner', 'Beginner'),
        ('Intermediate', 'Intermediate'),
        ('Advanced', 'Advanced'),
        ('Professional', 'Professional'),
    ]
    GENDER_CHOICES = [('Male', 'Male'), ('Female', 'Female'), ('Other', 'Other')]
    BLOOD_GROUP_CHOICES = [
        ('A+', 'A+'), ('A-', 'A-'), ('B+', 'B+'), ('B-', 'B-'),
        ('AB+', 'AB+'), ('AB-', 'AB-'), ('O+', 'O+'), ('O-', 'O-'),
    ]

    full_name = models.CharField(max_length=200)
    father_name = models.CharField(max_length=200)
    mobile_number = models.CharField(max_length=15)
    whatsapp_number = models.CharField(max_length=15, blank=True)
    date_of_birth = models.DateField()
    age = models.IntegerField(editable=False)
    gender = models.CharField(max_length=10, choices=GENDER_CHOICES)
    address = models.TextField()
    join_date = models.DateField(auto_now_add=True)
    batch = models.CharField(max_length=10, choices=BATCH_CHOICES)
    skill_level = models.CharField(max_length=20, choices=SKILL_CHOICES)
    monthly_fee = models.DecimalField(max_digits=10, decimal_places=2)
    emergency_contact = models.CharField(max_length=15)
    blood_group = models.CharField(max_length=5, choices=BLOOD_GROUP_CHOICES)
    photo = models.ImageField(upload_to='students/', blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def save(self, *args, **kwargs):
        from datetime import date
        today = date.today()
        self.age = today.year - self.date_of_birth.year - (
            (today.month, today.day) <
            (self.date_of_birth.month, self.date_of_birth.day)
        )
        super().save(*args, **kwargs)

    def __str__(self):
        return self.full_name
