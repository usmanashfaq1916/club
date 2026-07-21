from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db.models import Count, Q
from datetime import date, timedelta
from .models import Attendance
from .serializers import AttendanceSerializer, BulkAttendanceSerializer


class AttendanceViewSet(viewsets.ModelViewSet):
    queryset = Attendance.objects.all()
    serializer_class = AttendanceSerializer
    filterset_fields = ['student', 'date', 'status']

    def get_queryset(self):
        qs = super().get_queryset()
        student_id = self.request.query_params.get('student_id')
        month = self.request.query_params.get('month')
        year = self.request.query_params.get('year')
        if student_id:
            qs = qs.filter(student_id=student_id)
        if month and year:
            qs = qs.filter(date__month=month, date__year=year)
        return qs

    @action(detail=False, methods=['post'])
    def bulk(self, request):
        serializer = BulkAttendanceSerializer(data=request.data, many=True)
        if serializer.is_valid():
            results = []
            for item in serializer.validated_data:
                att, _ = Attendance.objects.update_or_create(
                    student_id=item['student_id'],
                    date=item['date'],
                    defaults={'status': item['status']},
                )
                results.append(att)
            output = AttendanceSerializer(results, many=True)
            return Response(output.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['get'])
    def summary(self, request):
        today = date.today()
        month = int(request.query_params.get('month', today.month))
        year = int(request.query_params.get('year', today.year))
        records = Attendance.objects.filter(date__month=month, date__year=year)
        total = records.count()
        present = records.filter(status='Present').count()
        absent = records.filter(status='Absent').count()
        leave = records.filter(status='Leave').count()
        return Response({
            'total': total,
            'present': present,
            'absent': absent,
            'leave': leave,
            'percentage': round((present / total * 100) if total > 0 else 0, 1),
        })
