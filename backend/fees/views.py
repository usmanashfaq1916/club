from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
from .models import Fee
from .serializers import FeeSerializer
from accounts.permissions import DomainPermission


class FeeViewSet(viewsets.ModelViewSet):
    serializer_class = FeeSerializer
    permission_classes = [IsAuthenticated, DomainPermission]
    filterset_fields = ['student', 'status', 'month']

    def get_queryset(self):
        user = self.request.user
        if user.role == 'Admin':
            qs = Fee.objects.all()
        elif user.role == 'Coach':
            qs = Fee.objects.filter(student__coach=user)
        elif user.role == 'Parent':
            qs = Fee.objects.filter(student__parent=user)
        elif user.role == 'Student':
            qs = Fee.objects.filter(student__user=user)
        else:
            return Fee.objects.none()
        student_id = self.request.query_params.get('student_id')
        if student_id:
            qs = qs.filter(student_id=student_id)
        return qs

    @action(detail=False, methods=['get'])
    def defaulters(self, request):
        defaulters = self.get_queryset().filter(status='Pending')
        page = self.paginate_queryset(defaulters)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        serializer = self.get_serializer(defaulters, many=True)
        return Response(serializer.data)
