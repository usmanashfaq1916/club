from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q
from .models import Student
from .serializers import StudentSerializer, StudentPhotoSerializer
from accounts.permissions import DomainPermission


class StudentViewSet(viewsets.ModelViewSet):
    serializer_class = StudentSerializer
    permission_classes = [IsAuthenticated, DomainPermission]
    search_fields = ['full_name', 'mobile_number', 'father_name']
    filterset_fields = ['batch', 'skill_level', 'is_active']

    def get_queryset(self):
        user = self.request.user
        if user.role == 'Admin':
            return Student.objects.all()
        elif user.role == 'Coach':
            return Student.objects.filter(coach=user)
        elif user.role == 'Parent':
            return Student.objects.filter(parent=user)
        elif user.role == 'Student':
            return Student.objects.filter(user=user)
        return Student.objects.none()

    def perform_create(self, serializer):
        user = self.request.user
        save_kwargs = {}
        if user.academy_id:
            save_kwargs['academy'] = user.academy
        if user.role == 'Coach':
            save_kwargs['coach'] = user
        serializer.save(**save_kwargs)

    @action(detail=True, methods=['post'])
    def upload_photo(self, request, pk=None):
        student = self.get_object()
        serializer = StudentPhotoSerializer(data=request.data)
        if serializer.is_valid():
            student.photo = serializer.validated_data['photo']
            student.save()
            return Response({'photo_url': student.photo.url})
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['get'])
    def search(self, request):
        q = request.query_params.get('q', '')
        students = self.get_queryset()
        if q:
            students = students.filter(
                Q(full_name__icontains=q) |
                Q(mobile_number__icontains=q) |
                Q(father_name__icontains=q)
            )
        page = self.paginate_queryset(students)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        serializer = self.get_serializer(students, many=True)
        return Response(serializer.data)
