from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase, APIClient
from rest_framework import status
from datetime import date
from .models import Attendance
from students.models import Student

User = get_user_model()


class AttendanceModelTest(TestCase):
    def setUp(self):
        self.student = Student.objects.create(
            full_name='Test Student',
            father_name='Test Father',
            mobile_number='1111111111',
            date_of_birth=date(2010, 1, 1),
            gender='Male',
            address='Test Address',
            batch='Morning',
            skill_level='Beginner',
            monthly_fee=1000.00,
            emergency_contact='1111111112',
            blood_group='A+',
        )
        self.attendance = Attendance.objects.create(
            student=self.student,
            date=date(2026, 7, 22),
            status='Present',
        )

    def test_attendance_creation(self):
        self.assertEqual(self.attendance.student, self.student)
        self.assertEqual(self.attendance.status, 'Present')
        self.assertEqual(self.attendance.date, date(2026, 7, 22))

    def test_attendance_str(self):
        self.assertEqual(
            str(self.attendance),
            'Test Student - 2026-07-22 - Present',
        )

    def test_unique_together(self):
        with self.assertRaises(Exception):
            Attendance.objects.create(
                student=self.student,
                date=date(2026, 7, 22),
                status='Absent',
            )

    def test_attendance_status_choices(self):
        for i, status_choice in enumerate(['Present', 'Absent', 'Leave']):
            att = Attendance.objects.create(
                student=self.student,
                date=date(2026, 7, 23 + i),
                status=status_choice,
            )
            self.assertEqual(att.status, status_choice)


class AttendanceAPITest(APITestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            username='admin@test.com',
            email='admin@test.com',
            password='password123',
            full_name='Admin User',
            role='Admin',
        )
        self.client.force_authenticate(user=self.user)
        self.student = Student.objects.create(
            full_name='API Student',
            father_name='API Father',
            mobile_number='2222222222',
            date_of_birth=date(2010, 5, 15),
            gender='Male',
            address='API Address',
            batch='Morning',
            skill_level='Intermediate',
            monthly_fee=1500.00,
            emergency_contact='2222222223',
            blood_group='O+',
        )

    def test_mark_attendance(self):
        response = self.client.post('/api/attendance/', {
            'student': self.student.id,
            'date': '2026-07-22',
            'status': 'Present',
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['status'], 'Present')

    def test_list_attendance_by_date(self):
        Attendance.objects.create(
            student=self.student,
            date=date(2026, 7, 22),
            status='Present',
        )
        response = self.client.get('/api/attendance/', {'date': '2026-07-22'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['count'], 1)

    def test_bulk_attendance(self):
        data = [
            {'student_id': self.student.id, 'date': '2026-07-22', 'status': 'Present'},
        ]
        response = self.client.post('/api/attendance/bulk/', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]['status'], 'Present')

    def test_attendance_summary(self):
        Attendance.objects.create(
            student=self.student,
            date=date(2026, 7, 1),
            status='Present',
        )
        Attendance.objects.create(
            student=self.student,
            date=date(2026, 7, 2),
            status='Absent',
        )
        response = self.client.get(
            '/api/attendance/summary/',
            {'month': '7', 'year': '2026'},
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['total'], 2)
        self.assertEqual(response.data['present'], 1)
        self.assertEqual(response.data['absent'], 1)
        self.assertEqual(response.data['percentage'], 50.0)

    def test_attendance_without_auth(self):
        self.client.force_authenticate(user=None)
        response = self.client.post('/api/attendance/', {
            'student': self.student.id,
            'date': '2026-07-22',
            'status': 'Present',
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
