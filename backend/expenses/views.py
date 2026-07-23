from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .models import Expense
from .serializers import ExpenseSerializer
from accounts.permissions import DomainPermission


class ExpenseViewSet(viewsets.ModelViewSet):
    serializer_class = ExpenseSerializer
    permission_classes = [IsAuthenticated, DomainPermission]
    filterset_fields = ['category', 'date']

    def get_queryset(self):
        user = self.request.user
        if user.role == 'Admin':
            return Expense.objects.all()
        return Expense.objects.filter(academy=user.academy)

    def perform_create(self, serializer):
        serializer.save(
            academy=self.request.user.academy,
            created_by=self.request.user,
        )
