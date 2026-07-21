from django.urls import path
from . import views

urlpatterns = [
    path('students/pdf/', views.StudentReportView.as_view(), name='students-pdf'),
    path('attendance/pdf/', views.AttendanceReportView.as_view(), name='attendance-pdf'),
    path('defaulters/pdf/', views.DefaulterReportView.as_view(), name='defaulters-pdf'),
    path('financial/pdf/', views.FinancialReportView.as_view(), name='financial-pdf'),
    path('performance/pdf/', views.PerformanceReportView.as_view(), name='performance-pdf'),
]
