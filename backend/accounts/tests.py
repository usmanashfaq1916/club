from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase, APIClient
from rest_framework import status

User = get_user_model()


class UserModelTest(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='admin@test.com',
            email='admin@test.com',
            password='password123',
            full_name='Admin User',
            role='Admin',
            phone='9876543210',
        )

    def test_user_creation(self):
        self.assertEqual(self.user.email, 'admin@test.com')
        self.assertEqual(self.user.full_name, 'Admin User')
        self.assertEqual(self.user.role, 'Admin')
        self.assertEqual(self.user.phone, '9876543210')
        self.assertTrue(self.user.is_active)

    def test_user_str(self):
        self.assertEqual(str(self.user), 'Admin User (Admin)')

    def test_user_role_choices(self):
        user_coach = User.objects.create_user(
            username='coach@test.com',
            email='coach@test.com',
            password='password123',
            full_name='Coach User',
            role='Coach',
        )
        self.assertEqual(user_coach.role, 'Coach')

        user_parent = User.objects.create_user(
            username='parent@test.com',
            email='parent@test.com',
            password='password123',
            full_name='Parent User',
            role='Parent',
        )
        self.assertEqual(user_parent.role, 'Parent')


class AuthAPITest(APITestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            username='admin@test.com',
            email='admin@test.com',
            password='password123',
            full_name='Admin User',
            role='Admin',
        )

    def test_register_user(self):
        data = {
            'username': 'newuser@test.com',
            'email': 'newuser@test.com',
            'password': 'password123',
            'full_name': 'New User',
            'role': 'Coach',
        }
        response = self.client.post('/api/auth/register/', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['email'], 'newuser@test.com')

    def test_login_with_valid_credentials(self):
        response = self.client.post('/api/auth/login/', {
            'username': 'admin@test.com',
            'password': 'password123',
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data)
        self.assertIn('refresh', response.data)

    def test_login_with_invalid_credentials(self):
        response = self.client.post('/api/auth/login/', {
            'username': 'admin@test.com',
            'password': 'wrongpassword',
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_profile_requires_auth(self):
        response = self.client.get('/api/auth/profile/')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_profile_authenticated(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.get('/api/auth/profile/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['email'], 'admin@test.com')
        self.assertEqual(response.data['role'], 'Admin')
