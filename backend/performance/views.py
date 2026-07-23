from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .models import Performance
from .serializers import PerformanceSerializer
from accounts.permissions import DomainPermission


class PerformanceViewSet(viewsets.ModelViewSet):
    serializer_class = PerformanceSerializer
    permission_classes = [IsAuthenticated, DomainPermission]
    filterset_fields = ['student']

    def get_queryset(self):
        user = self.request.user
        if user.role == 'Admin':
            qs = Performance.objects.all()
        elif user.role == 'Coach':
            qs = Performance.objects.filter(student__coach=user)
        elif user.role == 'Parent':
            qs = Performance.objects.filter(student__parent=user)
        elif user.role == 'Student':
            qs = Performance.objects.filter(student__user=user)
        else:
            return Performance.objects.none()
        student_id = self.request.query_params.get('student_id')
        if student_id:
            qs = qs.filter(student_id=student_id)
        return qs
