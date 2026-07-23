from rest_framework.permissions import BasePermission


class DomainPermission(BasePermission):
    def has_object_permission(self, request, view, obj):
        user = request.user
        if user.role == 'Admin':
            return True
        academy = getattr(obj, 'academy', None)
        if academy:
            return academy == user.academy
        return True
