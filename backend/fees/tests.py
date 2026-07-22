from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase, APIClient
from rest_framework import status
from datetime import date
from .models import Fee
from students.models import Student

User = get_user_model()


class FeeModelTest(TestCase):
    def setUp(self):
        self.student = Student.objects.create(
            full_name='Fee Student',
            father_name='Fee Father',
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
        self.fee = Fee.objects.create(
            student=self.student,
            month='July 2026',
            monthly_fee=1000.00,
            paid_amount=1000.00,
            balance=0,
            due_date=date(2026, 7, 10),
            payment_date=date(2026, 7, 5),
            payment_method='Cash',
            receipt_number='RCP001',
            status='Paid',
        )

    def test_fee_creation(self):
        self.assertEqual(self.fee.student, self.student)
        self.assertEqual(self.fee.month, 'July 2026')
        self.assertEqual(self.fee.monthly_fee, 1000.00)
        self.assertEqual(self.fee.paid_amount, 1000.00)
        self.assertEqual(self.fee.balance, 0)
        self.assertEqual(self.fee.status, 'Paid')

    def test_fee_str(self):
        self.assertEqual(str(self.fee), 'Fee Student - July 2026')

    def test_fee_status_choices(self):
        for status_choice in ['Paid', 'Partial', 'Pending']:
            f = Fee.objects.create(
                student=self.student,
                month='Test Month',
                monthly_fee=1000,
                due_date=date(2026, 8, 10),
                status=status_choice,
            )
            self.assertEqual(f.status, status_choice)

    def test_fee_default_status(self):
        f = Fee.objects.create(
            student=self.student,
            month='Default Month',
            monthly_fee=1000,
            due_date=date(2026, 9, 10),
        )
        self.assertEqual(f.status, 'Pending')
        self.assertEqual(f.paid_amount, 0)
        self.assertEqual(f.balance, 0)

    def test_partial_payment(self):
        f = Fee.objects.create(
            student=self.student,
            month='Partial Month',
            monthly_fee=1500,
            paid_amount=1000,
            balance=500,
            due_date=date(2026, 10, 10),
            payment_date=date(2026, 10, 5),
            payment_method='UPI',
            status='Partial',
        )
        self.assertEqual(f.paid_amount, 1000)
        self.assertEqual(f.balance, 500)
        self.assertEqual(f.status, 'Partial')


class FeeAPITest(APITestCase):
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
            full_name='API Fee Student',
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

    def test_create_fee(self):
        response = self.client.post('/api/fees/', {
            'student': self.student.id,
            'month': 'July 2026',
            'monthly_fee': '1500.00',
            'due_date': '2026-07-10',
            'paid_amount': '1500.00',
            'payment_method': 'Cash',
            'status': 'Paid',
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['month'], 'July 2026')

    def test_list_fees(self):
        Fee.objects.create(
            student=self.student,
            month='July 2026',
            monthly_fee=1500,
            paid_amount=1500,
            due_date=date(2026, 7, 10),
            status='Paid',
        )
        response = self.client.get('/api/fees/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['count'], 1)

    def test_list_fees_by_student(self):
        Fee.objects.create(
            student=self.student,
            month='July 2026',
            monthly_fee=1500,
            paid_amount=1500,
            due_date=date(2026, 7, 10),
            status='Paid',
        )
        response = self.client.get('/api/fees/', {'student_id': self.student.id})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['count'], 1)

    def test_defaulters_list(self):
        Fee.objects.create(
            student=self.student,
            month='July 2026',
            monthly_fee=1500,
            paid_amount=0,
            due_date=date(2026, 7, 10),
            status='Pending',
        )
        response = self.client.get('/api/fees/defaulters/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['count'], 1)

    def test_fee_without_auth(self):
        self.client.force_authenticate(user=None)
        response = self.client.post('/api/fees/', {
            'student': self.student.id,
            'month': 'July 2026',
            'monthly_fee': '1500.00',
            'due_date': '2026-07-10',
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
