from rest_framework import serializers
from .models import Attendance


class AttendanceSerializer(serializers.ModelSerializer):
    student_name = serializers.CharField(source='student.full_name', read_only=True)

    class Meta:
        model = Attendance
        fields = '__all__'


class BulkAttendanceSerializer(serializers.Serializer):
    student_id = serializers.IntegerField()
    date = serializers.DateField()
    status = serializers.ChoiceField(choices=['Present', 'Absent', 'Late', 'Leave'])

    def create(self, validated_data):
        attendance, _ = Attendance.objects.update_or_create(
            student_id=validated_data['student_id'],
            date=validated_data['date'],
            defaults={'status': validated_data['status']},
        )
        return attendance
