from django.db import models
from django.conf import settings


class MatchRecord(models.Model):
    RESULT_CHOICES = [
        ('Win', 'Win'),
        ('Loss', 'Loss'),
        ('Draw', 'Draw'),
        ('Cancelled', 'Cancelled'),
    ]
    match_date = models.DateField()
    opponent = models.CharField(max_length=200)
    venue = models.CharField(max_length=200, blank=True)
    runs = models.IntegerField(default=0)
    wickets = models.IntegerField(default=0)
    catches = models.IntegerField(default=0)
    strike_rate = models.FloatField(default=0)
    economy = models.FloatField(default=0)
    result = models.CharField(max_length=20, choices=RESULT_CHOICES)
    is_man_of_the_match = models.BooleanField(default=False)
    academy = models.ForeignKey(
        'accounts.Academy', on_delete=models.SET_NULL, null=True, blank=True,
        related_name='matches'
    )
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-match_date']

    def __str__(self):
        return f'vs {self.opponent} - {self.match_date}'
