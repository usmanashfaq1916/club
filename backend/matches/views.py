from rest_framework import viewsets
from .models import MatchRecord
from .serializers import MatchRecordSerializer


class MatchRecordViewSet(viewsets.ModelViewSet):
    queryset = MatchRecord.objects.all()
    serializer_class = MatchRecordSerializer
    filterset_fields = ['result', 'opponent']
