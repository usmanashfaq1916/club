from django.db.models import Sum, Count, Q
from django.utils import timezone
from datetime import datetime
from rest_framework.views import APIView
from rest_framework.response import Response
from students.models import Student
from attendance.models import Attendance
from fees.models import Fee
from expenses.models import Expense


def _get_student_qs(user):
    if user.role == 'Admin':
        return Student.objects.all()
    elif user.role == 'Coach':
        return Student.objects.filter(coach=user)
    elif user.role == 'Parent':
        return Student.objects.filter(parent=user)
    elif user.role == 'Student':
        return Student.objects.filter(user=user)
    return Student.objects.none()


class DashboardView(APIView):
    def get(self, request):
        user = request.user
        now = timezone.now()
        month_start = now.replace(day=1)
        today = now.date()

        students_qs = _get_student_qs(user)
        total_students = students_qs.count()
        active_students = students_qs.filter(is_active=True).count()

        today_attendance = Attendance.objects.filter(
            student__in=students_qs, date=today
        )
        total_today = today_attendance.count()
        present_today = today_attendance.filter(status='Present').count()

        all_fees = Fee.objects.filter(student__in=students_qs)
        total_collected = all_fees.aggregate(s=Sum('paid_amount'))['s'] or 0
        pending = all_fees.filter(status='Pending').aggregate(
            s=Sum('monthly_fee')
        )['s'] or 0

        month_fees = all_fees.filter(due_date__gte=month_start)
        monthly_income = month_fees.aggregate(s=Sum('paid_amount'))['s'] or 0

        month_expenses = Expense.objects.filter(
            academy=user.academy, date__gte=month_start
        )
        monthly_expenses = month_expenses.aggregate(s=Sum('amount'))['s'] or 0

        recent_activities = []
        recent_students = students_qs.order_by('-created_at')[:5]
        for s in recent_students:
            recent_activities.append({
                'type': 'student_added',
                'message': f'{s.full_name} joined',
                'date': s.created_at.isoformat(),
            })

        fee_due_list = []
        upcoming_fees = all_fees.filter(status__in=['Pending', 'Partial']).order_by('due_date')[:5]
        for f in upcoming_fees:
            fee_due_list.append({
                'student_name': f.student.full_name,
                'amount': float(f.balance or f.monthly_fee),
                'due_date': f.due_date.isoformat(),
                'status': f.status,
            })

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
            'recent_activities': recent_activities,
            'fee_due_list': fee_due_list,
        })
