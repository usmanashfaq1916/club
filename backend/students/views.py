from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db.models import Q
from .models import Student
from .serializers import StudentSerializer, StudentPhotoSerializer


class StudentViewSet(viewsets.ModelViewSet):
    queryset = Student.objects.all()
    serializer_class = StudentSerializer
    search_fields = ['full_name', 'mobile_number', 'father_name']
    filterset_fields = ['batch', 'skill_level', 'is_active']

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
        if q:
            students = Student.objects.filter(
                Q(full_name__icontains=q) |
                Q(mobile_number__icontains=q) |
                Q(father_name__icontains=q)
            )
        else:
            students = Student.objects.all()
        page = self.paginate_queryset(students)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        serializer = self.get_serializer(students, many=True)
        return Response(serializer.data)
