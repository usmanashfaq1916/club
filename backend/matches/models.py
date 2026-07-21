from django.db import models


class MatchRecord(models.Model):
    RESULT_CHOICES = [
        ('Win', 'Win'),
        ('Loss', 'Loss'),
        ('Draw', 'Draw'),
        ('Cancelled', 'Cancelled'),
    ]
    match_date = models.DateField()
    opponent = models.CharField(max_length=200)
    runs = models.IntegerField(default=0)
    wickets = models.IntegerField(default=0)
    catches = models.IntegerField(default=0)
    strike_rate = models.FloatField(default=0)
    economy = models.FloatField(default=0)
    result = models.CharField(max_length=20, choices=RESULT_CHOICES)
    is_man_of_the_match = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-match_date']

    def __str__(self):
        return f'vs {self.opponent} - {self.match_date}'
