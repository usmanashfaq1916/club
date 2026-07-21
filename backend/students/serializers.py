from rest_framework import serializers
from .models import Student


class StudentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Student
        fields = '__all__'
        read_only_fields = ['age', 'join_date', 'created_at', 'updated_at']


class StudentPhotoSerializer(serializers.Serializer):
    photo = serializers.ImageField()
