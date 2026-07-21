from django.db import models
from students.models import Student


class Performance(models.Model):
    student = models.ForeignKey(
        Student, on_delete=models.CASCADE, related_name='performances'
    )
    date = models.DateField(auto_now_add=True)
    batting_rating = models.IntegerField(default=5)
    bowling_rating = models.IntegerField(default=5)
    fielding_rating = models.IntegerField(default=5)
    fitness_rating = models.IntegerField(default=5)
    discipline_rating = models.IntegerField(default=5)
    coach_remarks = models.TextField(blank=True)
    overall_rating = models.FloatField(default=5, editable=False)

    class Meta:
        ordering = ['-date']

    def save(self, *args, **kwargs):
        self.overall_rating = (
            self.batting_rating + self.bowling_rating + self.fielding_rating +
            self.fitness_rating + self.discipline_rating
        ) / 5.0
        super().save(*args, **kwargs)

    def __str__(self):
        return f'{self.student.full_name} - {self.date}'
