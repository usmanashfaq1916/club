import io
from datetime import date
from django.http import HttpResponse
from django.db.models import Sum
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas
from reportlab.lib import colors
from reportlab.platypus import Table, TableStyle
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


class BaseReportMixin:
    def _write_header(self, c, title):
        c.setFont("Helvetica-Bold", 18)
        c.drawString(50, 800, "Young Fighters Academy")
        c.setFont("Helvetica", 12)
        c.drawString(50, 780, title)
        c.setFont("Helvetica", 9)
        c.drawString(50, 765, f"Generated: {date.today()}")
        c.line(50, 755, 545, 755)

    def _make_table(self, data, headers):
        table_data = [headers] + data
        t = Table(table_data, repeatRows=1)
        t.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#1B5E20')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
            ('FONTSIZE', (0, 0), (-1, -1), 9),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#F5F5F5')]),
        ]))
        return t


class StudentReportView(BaseReportMixin, APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        buffer = io.BytesIO()
        c = canvas.Canvas(buffer, pagesize=A4)
        self._write_header(c, "Student Report")
        students = _get_student_qs(request.user)
        data = [[s.full_name, s.father_name, s.mobile_number, s.batch,
                 f"Rs.{s.monthly_fee:.0f}"] for s in students]
        headers = ['Name', 'Father', 'Mobile', 'Batch', 'Fee']
        table = self._make_table(data, headers)
        table.wrapOn(c, 500, 700)
        table.drawOn(c, 50, 550)
        c.save()
        buffer.seek(0)
        return HttpResponse(buffer, content_type='application/pdf',
                            headers={'Content-Disposition': 'attachment; filename=student_report.pdf'})


class AttendanceReportView(BaseReportMixin, APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        buffer = io.BytesIO()
        c = canvas.Canvas(buffer, pagesize=A4)
        self._write_header(c, "Attendance Report")
        month = request.query_params.get('month', date.today().month)
        year = request.query_params.get('year', date.today().year)
        students = _get_student_qs(request.user)
        records = Attendance.objects.filter(
            student__in=students, date__month=month, date__year=year
        )
        data = [[r.student.full_name, str(r.date), r.status] for r in records]
        headers = ['Student', 'Date', 'Status']
        table = self._make_table(data, headers)
        table.wrapOn(c, 500, 700)
        table.drawOn(c, 50, 600)
        c.save()
        buffer.seek(0)
        return HttpResponse(buffer, content_type='application/pdf',
                            headers={'Content-Disposition': 'attachment; filename=attendance_report.pdf'})


class DefaulterReportView(BaseReportMixin, APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        buffer = io.BytesIO()
        c = canvas.Canvas(buffer, pagesize=A4)
        self._write_header(c, "Fee Defaulter Report")
        students = _get_student_qs(request.user)
        defaulters = Fee.objects.filter(student__in=students, status='Pending')
        data = [[f.student.full_name, f.month, f"Rs.{f.monthly_fee:.0f}",
                 str(f.due_date)] for f in defaulters]
        headers = ['Student', 'Month', 'Amount', 'Due Date']
        table = self._make_table(data, headers)
        table.wrapOn(c, 500, 700)
        table.drawOn(c, 50, 600)
        c.save()
        buffer.seek(0)
        return HttpResponse(buffer, content_type='application/pdf',
                            headers={'Content-Disposition': 'attachment; filename=defaulter_report.pdf'})


class FinancialReportView(BaseReportMixin, APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        buffer = io.BytesIO()
        c = canvas.Canvas(buffer, pagesize=A4)
        self._write_header(c, "Financial Report")
        user = request.user
        if user.role == 'Admin':
            total_income = Fee.objects.aggregate(s=Sum('paid_amount'))['s'] or 0
            total_expenses = Expense.objects.aggregate(s=Sum('amount'))['s'] or 0
        else:
            students = _get_student_qs(user)
            total_income = Fee.objects.filter(student__in=students).aggregate(
                s=Sum('paid_amount')
            )['s'] or 0
            total_expenses = Expense.objects.filter(academy=user.academy).aggregate(
                s=Sum('amount')
            )['s'] or 0
        net = total_income - total_expenses

        c.setFont("Helvetica", 14)
        c.drawString(50, 700, f"Total Income: Rs.{total_income:.2f}")
        c.drawString(50, 675, f"Total Expenses: Rs.{total_expenses:.2f}")
        c.drawString(50, 650, f"Net Profit: Rs.{net:.2f}")
        c.save()
        buffer.seek(0)
        return HttpResponse(buffer, content_type='application/pdf',
                            headers={'Content-Disposition': 'attachment; filename=financial_report.pdf'})


class PerformanceReportView(BaseReportMixin, APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        from performance.models import Performance
        buffer = io.BytesIO()
        c = canvas.Canvas(buffer, pagesize=A4)
        self._write_header(c, "Performance Report")
        students = _get_student_qs(request.user)
        performances = Performance.objects.filter(student__in=students)[:100]
        data = [[p.student.full_name, p.batting_rating, p.bowling_rating,
                 p.fielding_rating, p.fitness_rating, p.discipline_rating,
                 f"{p.overall_rating:.1f}"] for p in performances]
        headers = ['Student', 'Bat', 'Bowl', 'Field', 'Fit', 'Disc', 'Overall']
        table = self._make_table(data, headers)
        table.wrapOn(c, 500, 700)
        table.drawOn(c, 50, 600)
        c.save()
        buffer.seek(0)
        return HttpResponse(buffer, content_type='application/pdf',
                            headers={'Content-Disposition': 'attachment; filename=performance_report.pdf'})
