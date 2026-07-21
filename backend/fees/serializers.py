from rest_framework import serializers
from .models import Fee


class FeeSerializer(serializers.ModelSerializer):
    student_name = serializers.CharField(source='student.full_name', read_only=True)

    class Meta:
        model = Fee
        fields = '__all__'
