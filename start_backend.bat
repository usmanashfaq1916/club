@echo off
cd /d "%~dp0backend"
echo Starting Young Fighters Academy backend server on 0.0.0.0:8000...
python manage.py runserver 0.0.0.0:8000
pause
