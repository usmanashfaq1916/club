from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .models import MatchRecord
from .serializers import MatchRecordSerializer
from accounts.permissions import DomainPermission


class MatchRecordViewSet(viewsets.ModelViewSet):
    serializer_class = MatchRecordSerializer
    permission_classes = [IsAuthenticated, DomainPermission]
    filterset_fields = ['result', 'opponent']

    def get_queryset(self):
        user = self.request.user
        if user.role == 'Admin':
            return MatchRecord.objects.all()
        return MatchRecord.objects.filter(academy=user.academy)

    def perform_create(self, serializer):
        serializer.save(
            academy=self.request.user.academy,
            created_by=self.request.user,
        )
