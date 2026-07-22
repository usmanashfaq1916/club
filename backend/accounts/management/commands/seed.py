from django.core.management.base import BaseCommand
from accounts.models import User


class Command(BaseCommand):
    help = 'Seed the database with initial users'

    def handle(self, *args, **options):
        if User.objects.filter(email='admin@yfa.com').exists():
            self.stdout.write('Admin user already exists')
            return

        User.objects.create_superuser(
            username='admin@yfa.com',
            email='admin@yfa.com',
            password='admin123',
            full_name='Admin User',
            role='Admin',
            phone='',
        )
        self.stdout.write(self.style.SUCCESS('Admin user created: admin@yfa.com / admin123'))
