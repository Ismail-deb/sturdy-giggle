@echo off
echo Starting EcoView Backend...
start "EcoView Backend" cmd /k "cd /d C:\Users\griff\Downloads\flutter_python_app && .venv\Scripts\Activate.ps1 && python python_backend\app.py"

timeout /t 3 /nobreak > nul

echo Starting EcoView App in Chrome...
cd /d C:\Users\griff\Downloads\flutter_python_app\flutter_frontend
flutter run -d chrome
