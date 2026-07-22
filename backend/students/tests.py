from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase, APIClient
from rest_framework import status
from datetime import date
from .models import Student

User = get_user_model()


class StudentModelTest(TestCase):
    def setUp(self):
        self.student = Student.objects.create(
            full_name='Rahul Sharma',
            father_name='Raj Sharma',
            mobile_number='9876543210',
            date_of_birth=date(2010, 5, 15),
            gender='Male',
            address='123 Main St, Mumbai',
            batch='Morning',
            skill_level='Intermediate',
            monthly_fee=1500.00,
            emergency_contact='9876543211',
            blood_group='O+',
        )

    def test_student_creation(self):
        self.assertEqual(self.student.full_name, 'Rahul Sharma')
        self.assertEqual(self.student.father_name, 'Raj Sharma')
        self.assertEqual(self.student.mobile_number, '9876543210')
        self.assertEqual(self.student.batch, 'Morning')
        self.assertEqual(self.student.skill_level, 'Intermediate')
        self.assertTrue(self.student.is_active)

    def test_age_calculated_automatically(self):
        today = date.today()
        expected_age = today.year - 2010 - (
            (today.month, today.day) < (5, 15)
        )
        self.assertEqual(self.student.age, expected_age)

    def test_student_str(self):
        self.assertEqual(str(self.student), 'Rahul Sharma')

    def test_default_ordering(self):
        s2 = Student.objects.create(
            full_name='Virat Singh',
            father_name='Ravi Singh',
            mobile_number='9988776655',
            date_of_birth=date(2011, 8, 20),
            gender='Male',
            address='456 Park Ave, Delhi',
            batch='Evening',
            skill_level='Beginner',
            monthly_fee=1200.00,
            emergency_contact='9988776654',
            blood_group='B+',
        )
        students = Student.objects.all()
        self.assertEqual(students.first().full_name, 'Virat Singh')

    def test_inactive_student(self):
        self.student.is_active = False
        self.student.save()
        self.assertFalse(self.student.is_active)


class StudentAPITest(APITestCase):
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

    def test_list_students_empty(self):
        response = self.client.get('/api/students/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['count'], 0)

    def test_create_student(self):
        data = {
            'full_name': 'Test Student',
            'father_name': 'Test Father',
            'mobile_number': '1111111111',
            'date_of_birth': '2012-03-10',
            'gender': 'Male',
            'address': 'Test Address',
            'batch': 'Morning',
            'skill_level': 'Beginner',
            'monthly_fee': '1000.00',
            'emergency_contact': '1111111112',
            'blood_group': 'A+',
        }
        response = self.client.post('/api/students/', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['full_name'], 'Test Student')

    def test_create_student_without_auth(self):
        self.client.force_authenticate(user=None)
        data = {
            'full_name': 'Test Student',
            'father_name': 'Test Father',
            'mobile_number': '1111111111',
            'date_of_birth': '2012-03-10',
            'gender': 'Male',
            'address': 'Test Address',
            'batch': 'Morning',
            'skill_level': 'Beginner',
            'monthly_fee': '1000.00',
            'emergency_contact': '1111111112',
            'blood_group': 'A+',
        }
        response = self.client.post('/api/students/', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_get_student_detail(self):
        student = Student.objects.create(
            full_name='Detail Student',
            father_name='Detail Father',
            mobile_number='2222222222',
            date_of_birth=date(2010, 1, 1),
            gender='Female',
            address='Detail Address',
            batch='Evening',
            skill_level='Advanced',
            monthly_fee=2000.00,
            emergency_contact='2222222223',
            blood_group='AB+',
        )
        response = self.client.get(f'/api/students/{student.id}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['full_name'], 'Detail Student')

    def test_update_student(self):
        student = Student.objects.create(
            full_name='Update Student',
            father_name='Update Father',
            mobile_number='3333333333',
            date_of_birth=date(2010, 6, 15),
            gender='Male',
            address='Update Address',
            batch='Morning',
            skill_level='Intermediate',
            monthly_fee=1500.00,
            emergency_contact='3333333334',
            blood_group='O-',
        )
        response = self.client.patch(
            f'/api/students/{student.id}/',
            {'full_name': 'Updated Name'},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['full_name'], 'Updated Name')

    def test_delete_student(self):
        student = Student.objects.create(
            full_name='Delete Student',
            father_name='Delete Father',
            mobile_number='4444444444',
            date_of_birth=date(2011, 3, 20),
            gender='Male',
            address='Delete Address',
            batch='Evening',
            skill_level='Beginner',
            monthly_fee=1000.00,
            emergency_contact='4444444445',
            blood_group='B+',
        )
        response = self.client.delete(f'/api/students/{student.id}/')
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)

    def test_search_student(self):
        Student.objects.create(
            full_name='Searchable Student',
            father_name='Search Father',
            mobile_number='5555555555',
            date_of_birth=date(2010, 7, 10),
            gender='Male',
            address='Search Address',
            batch='Morning',
            skill_level='Advanced',
            monthly_fee=2000.00,
            emergency_contact='5555555556',
            blood_group='A+',
        )
        response = self.client.get('/api/students/search/', {'q': 'Searchable'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['count'], 1)

    def test_filter_by_batch(self):
        Student.objects.create(
            full_name='Morning Student',
            father_name='M Father',
            mobile_number='6666666666',
            date_of_birth=date(2010, 1, 1),
            gender='Male',
            address='Addr',
            batch='Morning',
            skill_level='Beginner',
            monthly_fee=1000.00,
            emergency_contact='6666666667',
            blood_group='A+',
        )
        Student.objects.create(
            full_name='Evening Student',
            father_name='E Father',
            mobile_number='7777777777',
            date_of_birth=date(2010, 2, 2),
            gender='Female',
            address='Addr2',
            batch='Evening',
            skill_level='Intermediate',
            monthly_fee=1500.00,
            emergency_contact='7777777778',
            blood_group='B+',
        )
        response = self.client.get('/api/students/', {'batch': 'Morning'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['count'], 1)
