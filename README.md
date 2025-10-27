# Greenhouse Monitoring App

A full-stack application for monitoring and analyzing greenhouse environmental conditions.

## Overview

This project consists of:

1. **Flask Backend** - A Python server providing APIs for sensor data
2. **Flutter Frontend** - A mobile app displaying real-time sensor data with a modern UI

## Features

- Real-time monitoring of temperature, humidity, CO2, light, and other greenhouse parameters
- Historical data visualization
- Alerts and notifications for critical conditions
- AI-powered recommendations for optimal growing conditions

## Setup

### Backend Setup

1. Navigate to the backend directory:
   ```
   cd python_backend
   ```

2. Create a virtual environment and activate it:
   ```
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

4. Run the Flask server:
   ```
   python app.py
   ```

### Frontend Setup

1. Navigate to the frontend directory:
   ```
   cd flutter_frontend
   ```

2. Install Flutter dependencies:
   ```
   flutter pub get
   ```

3. Run the app:
   ```
   flutter run
   ```

## Configuration

The Flutter app connects to the Flask backend using the IP address configured in `api_service.dart`.

## License

[MIT License](LICENSE)