from django.db.models import Sum, Count, Q
from django.utils import timezone
from datetime import datetime
from rest_framework.views import APIView
from rest_framework.response import Response
from students.models import Student
from attendance.models import Attendance
from fees.models import Fee
from expenses.models import Expense


class DashboardView(APIView):
    def get(self, request):
        now = timezone.now()
        month_start = now.replace(day=1)
        today = now.date()

        total_students = Student.objects.count()
        active_students = Student.objects.filter(is_active=True).count()

        today_attendance = Attendance.objects.filter(date=today)
        total_today = today_attendance.count()
        present_today = today_attendance.filter(status='Present').count()

        all_fees = Fee.objects.all()
        total_collected = all_fees.aggregate(s=Sum('paid_amount'))['s'] or 0
        pending = all_fees.filter(status='Pending').aggregate(
            s=Sum('monthly_fee')
        )['s'] or 0

        month_fees = all_fees.filter(due_date__gte=month_start)
        monthly_income = month_fees.aggregate(s=Sum('paid_amount'))['s'] or 0

        month_expenses = Expense.objects.filter(date__gte=month_start)
        monthly_expenses = month_expenses.aggregate(s=Sum('amount'))['s'] or 0

        return Response({
            'total_students': total_students,
            'active_students': active_students,
            'present_today': present_today,
            'total_today': total_today,
            'attendance_percentage': round(
                (present_today / total_today * 100) if total_today > 0 else 0, 1
            ),
            'fee_collected': float(total_collected),
            'pending_fees': float(pending),
            'monthly_income': float(monthly_income),
            'monthly_expenses': float(monthly_expenses),
            'net_profit': float(monthly_income - monthly_expenses),
        })
