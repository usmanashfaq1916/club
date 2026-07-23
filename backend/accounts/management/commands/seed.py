from django.core.management.base import BaseCommand
from accounts.models import User, Academy


class Command(BaseCommand):
    help = 'Seed the database with initial users'

    def handle(self, *args, **options):
        academy, _ = Academy.objects.get_or_create(
            name='Young Fighters Academy',
            defaults={'location': 'Main Campus'},
        )
        self.stdout.write(f'Academy: {academy.name}')

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
            academy=academy,
        )
        self.stdout.write(self.style.SUCCESS('Admin user created: admin@yfa.com / admin123'))
