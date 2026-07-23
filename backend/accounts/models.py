from django.contrib.auth.models import AbstractUser
from django.db import models


class Academy(models.Model):
    name = models.CharField(max_length=200)
    location = models.CharField(max_length=200, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name_plural = 'Academies'

    def __str__(self):
        return self.name


class User(AbstractUser):
    ROLE_CHOICES = [
        ('Admin', 'Admin'),
        ('Coach', 'Coach'),
        ('Parent', 'Parent'),
        ('Student', 'Student'),
    ]
    full_name = models.CharField(max_length=100, default='')
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='Admin')
    phone = models.CharField(max_length=15, blank=True)
    photo = models.ImageField(upload_to='users/', blank=True)
    academy = models.ForeignKey(
        Academy, on_delete=models.SET_NULL, null=True, blank=True,
        related_name='users'
    )
    is_active = models.BooleanField(default=True)

    groups = models.ManyToManyField(
        'auth.Group', related_name='accounts_user_set', blank=True
    )
    user_permissions = models.ManyToManyField(
        'auth.Permission', related_name='accounts_user_set', blank=True
    )

    def __str__(self):
        return f'{self.full_name} ({self.role})'
