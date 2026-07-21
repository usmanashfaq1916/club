from rest_framework import serializers
from .models import Performance


class PerformanceSerializer(serializers.ModelSerializer):
    student_name = serializers.CharField(source='student.full_name', read_only=True)

    class Meta:
        model = Performance
        fields = '__all__'
        read_only_fields = ['overall_rating', 'date']
