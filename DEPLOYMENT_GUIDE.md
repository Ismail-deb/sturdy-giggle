# EcoView Greenhouse Monitoring System - Deployment Guide

## Table of Contents
1. [Overview](#overview)
2. [System Requirements](#system-requirements)
3. [Architecture Overview](#architecture-overview)
4. [Pre-Deployment Checklist](#pre-deployment-checklist)
5. [Backend Deployment](#backend-deployment)
6. [Frontend Deployment](#frontend-deployment)
7. [Hardware Setup](#hardware-setup)
8. [Configuration](#configuration)
9. [Testing](#testing)
10. [Troubleshooting](#troubleshooting)
11. [Maintenance & Updates](#maintenance--updates)
12. [Security Best Practices](#security-best-practices)

---

## Overview

The EcoView Greenhouse Monitoring System consists of three main components:
- **Python Backend**: Flask-based REST API with MQTT integration
- **Flutter Frontend**: Cross-platform mobile application
- **IoT Hardware**: ESP32/Arduino with various sensors

This guide provides step-by-step instructions for deploying and configuring all components.

---

## System Requirements

### Development Machine
- **OS**: Windows 10/11, macOS 10.15+, or Linux (Ubuntu 20.04+)
- **RAM**: Minimum 8GB (16GB recommended)
- **Storage**: 10GB free space
- **Internet**: Stable connection for package downloads

### Backend Server
- **OS**: Windows Server 2019+ or Linux (Ubuntu 20.04+)
- **RAM**: Minimum 2GB (4GB recommended)
- **CPU**: 2 cores minimum
- **Storage**: 5GB free space
- **Python**: Version 3.8 or higher
- **Network**: Static IP or domain name

### Mobile Devices
- **Android**: Version 7.0 (API 24) or higher
- **iOS**: Version 12.0 or higher
- **Storage**: 100MB free space
- **RAM**: 2GB minimum

### IoT Hardware
- **Microcontroller**: ESP32 or Arduino with WiFi module
- **Sensors**: DHT22 (temperature/humidity), MQ-135 (CO2), soil moisture sensor, LDR (light), flame sensor
- **Power**: 5V USB or battery pack
- **Network**: WiFi connection

---

## Architecture Overview

```
┌─────────────────┐
│  Mobile App     │
│  (Flutter)      │
└────────┬────────┘
         │ HTTP/HTTPS
         │
┌────────▼────────┐      MQTT      ┌──────────────┐
│  Flask Backend  │◄────────────────┤  MQTT Broker │
│  (Python)       │                 │  (Mosquitto) │
└────────┬────────┘                 └──────▲───────┘
         │                                 │
         │ SQLite/PostgreSQL               │ MQTT
         │                                 │
┌────────▼────────┐                 ┌──────┴───────┐
│    Database     │                 │   ESP32/     │
│                 │                 │   Arduino    │
└─────────────────┘                 │   Sensors    │
                                    └──────────────┘
```

---

## Pre-Deployment Checklist

### 1. Software Installation

#### Python (Backend)
```bash
# Verify Python installation
python --version  # Should be 3.8 or higher

# If not installed:
# Windows: Download from https://www.python.org/downloads/
# macOS: brew install python3
# Linux: sudo apt-get install python3 python3-pip
```

#### Flutter (Frontend)
```bash
# Download Flutter SDK from https://flutter.dev/docs/get-started/install

# Add to PATH
# Windows: Add C:\flutter\bin to System Environment Variables
# macOS/Linux: export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor

# Install Android Studio or Xcode for mobile development
```

#### Git
```bash
# Verify Git installation
git --version

# If not installed:
# Windows: Download from https://git-scm.com/download/win
# macOS: brew install git
# Linux: sudo apt-get install git
```

### 2. API Keys & Credentials

Obtain the following:
- **Google Gemini API Key**: https://makersuite.google.com/app/apikey
- **MQTT Broker Credentials**: If using cloud MQTT (e.g., HiveMQ, CloudMQTT)
- **Firebase Project** (optional): For push notifications

### 3. Network Configuration

- [ ] Static IP address for backend server (or domain name)
- [ ] Firewall rules allowing:
  - Port 5000 (Flask API)
  - Port 1883 (MQTT)
  - Port 8883 (MQTT SSL - optional)
- [ ] SSL certificates (for production)

---

## Backend Deployment

### Step 1: Clone Repository

```bash
# Clone the repository
git clone https://github.com/Ismail-deb/sturdy-giggle.git
cd sturdy-giggle/python_backend
```

### Step 2: Create Virtual Environment

```bash
# Windows
python -m venv venv
venv\Scripts\activate

# macOS/Linux
python3 -m venv venv
source venv/bin/activate
```

### Step 3: Install Dependencies

```bash
# Upgrade pip
pip install --upgrade pip

# Install required packages
pip install -r requirements.txt

# Verify installations
pip list
```

**Expected packages:**
- Flask (API framework)
- flask-cors (Cross-origin support)
- paho-mqtt (MQTT client)
- reportlab (PDF generation)
- google-generativeai (Gemini AI integration)

### Step 4: Configure Environment Variables

Create a `.env` file in `python_backend/`:

```bash
# .env file
FLASK_APP=app.py
FLASK_ENV=production
SECRET_KEY=your-secure-random-secret-key-here

# Gemini AI Configuration
GEMINI_API_KEY=your-gemini-api-key-here

# MQTT Configuration
MQTT_BROKER=your-mqtt-broker-address
MQTT_PORT=1883
MQTT_USERNAME=your-mqtt-username
MQTT_PASSWORD=your-mqtt-password

# Database Configuration
DATABASE_URL=sqlite:///greenhouse.db

# Server Configuration
HOST=0.0.0.0
PORT=5000
DEBUG=False
```

**Security Note**: Never commit `.env` to Git. Add it to `.gitignore`.

### Step 5: Initialize Database

```bash
# Run the application once to initialize database
python app.py

# The SQLite database will be created automatically
# For production, consider migrating to PostgreSQL
```

### Step 6: Configure MQTT Bridge

Edit `mqtt_bridge_requirements.txt` if needed, then:

```bash
# In a separate terminal (keep virtual environment active)
cd python_backend
python gemini_service.py

# This starts the MQTT listener for real-time sensor data
```

### Step 7: Test Backend

```bash
# Start Flask server
python app.py

# Server should start on http://localhost:5000

# Test endpoints:
curl http://localhost:5000/readings/latest
curl http://localhost:5000/ai-recommendations
```

### Step 8: Production Deployment Options

#### Option A: Using Gunicorn (Recommended for Linux)

```bash
# Install Gunicorn
pip install gunicorn

# Run with Gunicorn
gunicorn --bind 0.0.0.0:5000 --workers 4 --timeout 120 app:app

# For background process:
nohup gunicorn --bind 0.0.0.0:5000 --workers 4 app:app > app.log 2>&1 &
```

#### Option B: Using systemd Service (Linux)

Create `/etc/systemd/system/ecoview-backend.service`:

```ini
[Unit]
Description=EcoView Greenhouse Backend
After=network.target

[Service]
User=your-username
WorkingDirectory=/path/to/sturdy-giggle/python_backend
Environment="PATH=/path/to/venv/bin"
ExecStart=/path/to/venv/bin/gunicorn --bind 0.0.0.0:5000 --workers 4 app:app
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
# Enable and start service
sudo systemctl enable ecoview-backend
sudo systemctl start ecoview-backend
sudo systemctl status ecoview-backend
```

#### Option C: Using Windows Service

```bash
# Install pywin32
pip install pywin32

# Install as Windows service
python app.py install

# Start service
python app.py start
```

#### Option D: Docker Deployment

Create `Dockerfile` in `python_backend/`:

```dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "app:app"]
```

```bash
# Build Docker image
docker build -t ecoview-backend .

# Run container
docker run -d -p 5000:5000 --env-file .env --name ecoview-backend ecoview-backend
```

### Step 9: Setup Reverse Proxy (Production)

#### Using Nginx

```nginx
# /etc/nginx/sites-available/ecoview

server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_connect_timeout 120;
        proxy_send_timeout 120;
        proxy_read_timeout 120;
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/ecoview /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

#### SSL with Let's Encrypt

```bash
# Install Certbot
sudo apt-get install certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d your-domain.com

# Auto-renewal is configured automatically
```

---

## Frontend Deployment

### Step 1: Setup Flutter Project

```bash
cd sturdy-giggle/flutter_frontend

# Get dependencies
flutter pub get

# Verify no issues
flutter doctor
flutter analyze
```

### Step 2: Configure API Endpoint

Edit `lib/services/api_service.dart`:

```dart
class ApiService {
  // Development
  // static const String baseUrl = 'http://localhost:5000';
  
  // Production - Update with your server IP/domain
  static const String baseUrl = 'https://your-domain.com';
  
  // Or use IP address
  // static const String baseUrl = 'http://192.168.1.100:5000';
  
  // ...rest of code
}
```

### Step 3: Update App Configuration

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <!-- Add internet permission -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <!-- For notifications -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    
    <!-- Allow cleartext traffic for HTTP (development only) -->
    <application
        android:usesCleartextTraffic="true"
        ...>
```

**Production Note**: Remove `android:usesCleartextTraffic="true"` and use HTTPS only.

### Step 4: Configure App Icons

```bash
# Icons are already configured via flutter_launcher_icons
# To regenerate icons after changes:
flutter pub run flutter_launcher_icons
```

### Step 5: Build for Android

```bash
# Clean previous builds
flutter clean

# Build APK (for testing)
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### Step 6: Build for iOS (macOS only)

```bash
# Clean previous builds
flutter clean

# Install CocoaPods dependencies
cd ios
pod install
cd ..

# Build IPA
flutter build ios --release

# Archive and upload via Xcode
open ios/Runner.xcworkspace
```

### Step 7: Sign Android APK

#### Generate Keystore

```bash
# Generate signing key
keytool -genkey -v -keystore ecoview-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ecoview

# Follow prompts to set password and details
```

#### Configure Signing

Create `android/key.properties`:

```properties
storePassword=your-keystore-password
keyPassword=your-key-password
keyAlias=ecoview
storeFile=../ecoview-release-key.jks
```

Edit `android/app/build.gradle`:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### Step 8: Test APK

```bash
# Install on connected device
adb install build/app/outputs/flutter-apk/app-release.apk

# Or use Flutter
flutter install --release
```

### Step 9: Distribution Options

#### Option A: Direct Distribution
- Share APK file directly with users
- Users enable "Install from Unknown Sources"
- Install APK manually

#### Option B: Google Play Store
1. Create developer account: https://play.google.com/console
2. Create app listing
3. Upload `app-release.aab`
4. Complete store listing (descriptions, screenshots, etc.)
5. Submit for review

#### Option C: Internal Testing
- Use Firebase App Distribution
- TestFlight for iOS
- Google Play Internal Testing

---

## Hardware Setup

### Step 1: ESP32/Arduino Setup

#### Install Arduino IDE

```bash
# Download from https://www.arduino.cc/en/software

# Add ESP32 board support:
# File > Preferences > Additional Board Manager URLs:
https://dl.espressif.com/dl/package_esp32_index.json
```

#### Install Required Libraries

In Arduino IDE:
- Tools > Manage Libraries
- Install:
  - `DHT sensor library` by Adafruit
  - `Adafruit Unified Sensor`
  - `PubSubClient` (for MQTT)
  - `ArduinoJson`
  - `WiFi` (built-in for ESP32)

### Step 2: Hardware Connections

```
ESP32 Pin Connections:
├── DHT22 (Temperature/Humidity)
│   ├── VCC → 3.3V
│   ├── DATA → GPIO 4
│   └── GND → GND
│
├── MQ-135 (CO2/Air Quality)
│   ├── VCC → 5V
│   ├── AOUT → GPIO 34 (ADC)
│   └── GND → GND
│
├── Soil Moisture Sensor
│   ├── VCC → 3.3V
│   ├── AOUT → GPIO 35 (ADC)
│   └── GND → GND
│
├── LDR (Light Sensor)
│   ├── One end → 3.3V
│   ├── Other end → GPIO 32 (ADC) + 10kΩ resistor to GND
│
└── Flame Sensor
    ├── VCC → 3.3V
    ├── DOUT → GPIO 25
    └── GND → GND
```

### Step 3: Configure Sensor Code

Create `greenhouse_sensors.ino`:

```cpp
#include <WiFi.h>
#include <PubSubClient.h>
#include <DHT.h>
#include <ArduinoJson.h>

// WiFi credentials
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

// MQTT Configuration
const char* mqtt_server = "YOUR_MQTT_BROKER_IP";
const int mqtt_port = 1883;
const char* mqtt_user = "YOUR_MQTT_USERNAME";
const char* mqtt_password = "YOUR_MQTT_PASSWORD";
const char* mqtt_topic = "greenhouse/sensors";

// Pin definitions
#define DHTPIN 4
#define DHTTYPE DHT22
#define MQ135_PIN 34
#define SOIL_MOISTURE_PIN 35
#define LDR_PIN 32
#define FLAME_PIN 25

DHT dht(DHTPIN, DHTTYPE);
WiFiClient espClient;
PubSubClient client(espClient);

unsigned long lastMsg = 0;
const long interval = 5000; // Send data every 5 seconds

void setup() {
  Serial.begin(115200);
  pinMode(FLAME_PIN, INPUT);
  
  dht.begin();
  setup_wifi();
  client.setServer(mqtt_server, mqtt_port);
}

void setup_wifi() {
  delay(10);
  Serial.println("Connecting to WiFi...");
  WiFi.begin(ssid, password);
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  
  Serial.println("\nWiFi connected");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Connecting to MQTT...");
    if (client.connect("ESP32Client", mqtt_user, mqtt_password)) {
      Serial.println("connected");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" retrying in 5 seconds");
      delay(5000);
    }
  }
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();
  
  unsigned long now = millis();
  if (now - lastMsg > interval) {
    lastMsg = now;
    
    // Read sensors
    float temperature = dht.readTemperature();
    float humidity = dht.readHumidity();
    int co2_raw = analogRead(MQ135_PIN);
    int soil_raw = analogRead(SOIL_MOISTURE_PIN);
    int light_raw = analogRead(LDR_PIN);
    int flame = digitalRead(FLAME_PIN);
    
    // Convert readings
    float co2_ppm = map(co2_raw, 0, 4095, 400, 5000);
    float soil_percent = map(soil_raw, 0, 4095, 0, 100);
    float light_lux = map(light_raw, 0, 4095, 0, 10000);
    
    // Create JSON
    StaticJsonDocument<256> doc;
    doc["temperature"] = temperature;
    doc["humidity"] = humidity;
    doc["co2"] = co2_ppm;
    doc["soil_moisture"] = soil_percent;
    doc["light"] = light_lux;
    doc["flame"] = (flame == LOW) ? 1 : 0;
    doc["timestamp"] = millis();
    
    char buffer[256];
    serializeJson(doc, buffer);
    
    // Publish to MQTT
    client.publish(mqtt_topic, buffer);
    Serial.println(buffer);
  }
}
```

### Step 4: Upload to ESP32

1. Connect ESP32 via USB
2. Select Board: Tools > Board > ESP32 Dev Module
3. Select Port: Tools > Port > (your COM port)
4. Click Upload
5. Monitor Serial output to verify connection

### Step 5: Calibrate Sensors

```cpp
// Add calibration values based on your sensors
#define TEMP_OFFSET -2.0  // Adjust based on known reference
#define HUMIDITY_OFFSET 5.0
#define SOIL_DRY 3500  // ADC value in dry soil
#define SOIL_WET 1500  // ADC value in water

// Apply in code:
float calibrated_temp = temperature + TEMP_OFFSET;
float soil_percent = map(soil_raw, SOIL_WET, SOIL_DRY, 100, 0);
```

---

## Configuration

### Backend Configuration

#### Flask Settings (`app.py`)

```python
# Development
app.config['DEBUG'] = True
app.config['TESTING'] = False

# Production
app.config['DEBUG'] = False
app.config['TESTING'] = False

# CORS settings
CORS(app, resources={
    r"/*": {
        "origins": ["*"],  # Restrict in production
        "methods": ["GET", "POST", "PUT", "DELETE"],
        "allow_headers": ["Content-Type"]
    }
})

# Database connection pooling
app.config['SQLALCHEMY_POOL_SIZE'] = 10
app.config['SQLALCHEMY_POOL_TIMEOUT'] = 30
```

#### Gemini AI Configuration

```python
# Configure generation parameters
generation_config = {
    "temperature": 0.7,  # Lower = more focused, Higher = more creative
    "top_p": 0.95,
    "top_k": 40,
    "max_output_tokens": 1024,
}

safety_settings = [
    {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
    {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
]
```

#### MQTT Configuration

```python
# MQTT settings
MQTT_BROKER = os.getenv('MQTT_BROKER', 'localhost')
MQTT_PORT = int(os.getenv('MQTT_PORT', 1883))
MQTT_KEEPALIVE = 60
MQTT_TOPIC = "greenhouse/sensors"

# QoS levels:
# 0 = At most once (no guarantee)
# 1 = At least once (may duplicate)
# 2 = Exactly once (guaranteed, slower)
MQTT_QOS = 1
```

### Frontend Configuration

#### API Timeouts

```dart
// lib/services/api_service.dart
static const Duration timeoutDuration = Duration(seconds: 30);

Future<dynamic> _makeRequest(String endpoint) async {
  final response = await http
      .get(Uri.parse('$baseUrl$endpoint'))
      .timeout(timeoutDuration);
  // ...
}
```

#### Notification Settings

```dart
// Configure local notifications
final AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    
final InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

await flutterLocalNotificationsPlugin.initialize(initSettings);
```

### Threshold Configuration

Edit `python_backend/THRESHOLDS.md` for custom ranges:

```python
THRESHOLDS = {
    'temperature': {'min': 18.0, 'max': 28.0, 'optimal': 22.0},
    'humidity': {'min': 50.0, 'max': 70.0, 'optimal': 60.0},
    'co2': {'min': 400.0, 'max': 1200.0, 'optimal': 800.0},
    'soil_moisture': {'min': 30.0, 'max': 70.0, 'optimal': 50.0},
    'light': {'min': 2000.0, 'max': 8000.0, 'optimal': 5000.0},
}
```

---

## Testing

### Backend Testing

#### Unit Tests

```python
# test_api.py
import unittest
from app import app

class TestAPI(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True
    
    def test_latest_readings(self):
        response = self.app.get('/readings/latest')
        self.assertEqual(response.status_code, 200)
    
    def test_ai_recommendations(self):
        response = self.app.get('/ai-recommendations')
        self.assertIn(response.status_code, [200, 500])

if __name__ == '__main__':
    unittest.main()
```

Run tests:
```bash
python test_api.py
```

#### Load Testing

```bash
# Install Apache Bench
sudo apt-get install apache2-utils

# Test API endpoint
ab -n 1000 -c 10 http://localhost:5000/readings/latest

# Expected: <100ms average response time
```

### Frontend Testing

#### Widget Tests

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart

# With coverage
flutter test --coverage
```

#### Integration Tests

```bash
# Run integration tests on device
flutter drive --target=test_driver/app.dart
```

### End-to-End Testing

1. **Hardware to Backend**:
   ```bash
   # Monitor MQTT messages
   mosquitto_sub -h localhost -t "greenhouse/sensors" -v
   ```

2. **Backend to Frontend**:
   - Open app
   - Check dashboard updates
   - Verify real-time data flow

3. **Full Flow Test**:
   - Change sensor value (e.g., breathe on DHT22)
   - Observe MQTT message in broker
   - Check database entry
   - Verify app update
   - Generate PDF report
   - Request AI recommendations

---

## Troubleshooting

### Backend Issues

#### Problem: Flask won't start
```bash
# Check if port is in use
netstat -ano | findstr :5000  # Windows
lsof -i :5000  # Linux/macOS

# Kill process if needed
taskkill /PID <pid> /F  # Windows
kill -9 <pid>  # Linux/macOS

# Try different port
python app.py --port 5001
```

#### Problem: Database connection errors
```bash
# Check database file permissions
ls -l greenhouse.db

# Reset database
rm greenhouse.db
python app.py  # Recreates database

# For PostgreSQL connection issues
psql -h localhost -U postgres -d greenhouse  # Test connection
```

#### Problem: MQTT connection fails
```bash
# Test MQTT broker
mosquitto_pub -h <broker> -t test -m "hello"
mosquitto_sub -h <broker> -t test

# Check firewall
sudo ufw allow 1883/tcp

# Verify credentials
# Check MQTT_USERNAME and MQTT_PASSWORD in .env
```

#### Problem: Gemini API errors
```bash
# Verify API key
curl -H "Content-Type: application/json" \
     -H "x-goog-api-key: YOUR_API_KEY" \
     https://generativelanguage.googleapis.com/v1/models

# Check quota limits in Google Cloud Console
# Rate limit: 60 requests/minute
```

#### Problem: PDF generation fails
```bash
# Install reportlab dependencies
pip install --upgrade reportlab pillow

# Check write permissions
chmod 755 /tmp  # Linux/macOS

# Verify font availability
fc-list  # List available fonts
```

### Frontend Issues

#### Problem: Build fails
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub upgrade
flutter build apk --release

# Clear Gradle cache (Android)
cd android
./gradlew clean
cd ..
```

#### Problem: API connection errors
```dart
// Check network permissions in AndroidManifest.xml
<uses-permission android:name="android.permission.INTERNET" />

// Test API endpoint
curl http://<backend-ip>:5000/readings/latest

// Check for CORS issues in backend
// Enable cleartext traffic for HTTP (development only)
android:usesCleartextTraffic="true"
```

#### Problem: Charts not displaying
```bash
# Check fl_chart version
flutter pub deps | grep fl_chart

# Update if needed
flutter pub upgrade fl_chart

# Clear app cache on device
adb shell pm clear com.example.your_app
```

#### Problem: Notifications not working
```bash
# Check Android notification channel
// In app code, verify channel creation

# Grant notification permissions
adb shell pm grant com.example.your_app android.permission.POST_NOTIFICATIONS

# Test notification manually
// Use Flutter local notifications test method
```

### Hardware Issues

#### Problem: ESP32 won't connect to WiFi
```cpp
// Add debug output
Serial.print("Connecting to: ");
Serial.println(ssid);
Serial.print("WiFi status: ");
Serial.println(WiFi.status());

// Common issues:
// 1. Wrong SSID/password
// 2. 5GHz network (ESP32 only supports 2.4GHz)
// 3. Special characters in password
// 4. Network security (WPA2-Enterprise not supported)
```

#### Problem: Sensor readings are incorrect
```cpp
// Test individual sensors
void testSensors() {
  // DHT22
  Serial.print("Temperature: ");
  Serial.println(dht.readTemperature());
  
  // Analog sensors
  Serial.print("MQ-135 raw: ");
  Serial.println(analogRead(MQ135_PIN));
  
  delay(2000);
}

// Check connections with multimeter
// Verify voltage levels: VCC=3.3V or 5V, GND=0V
```

#### Problem: MQTT messages not received
```cpp
// Add callback function
void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  for (int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
  }
  Serial.println();
}

client.setCallback(callback);

// Subscribe to test topic
client.subscribe("test/message");
```

### Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| `Connection refused` | Backend not running | Start Flask server |
| `ECONNRESET` | Network timeout | Increase timeout duration |
| `401 Unauthorized` | Invalid API key | Check Gemini API key |
| `MQTT connection lost` | Broker offline | Restart MQTT broker |
| `Database locked` | Concurrent writes | Migrate to PostgreSQL |
| `Out of memory` | Large dataset | Implement pagination |
| `SSL certificate error` | Invalid/expired cert | Renew SSL certificate |
| `Permission denied` | File permissions | `chmod 755` or run as admin |

---

## Maintenance & Updates

### Regular Maintenance Tasks

#### Daily
- Monitor server logs for errors
- Check MQTT message flow
- Verify sensor connectivity

```bash
# Check backend logs
tail -f /var/log/ecoview/app.log

# Monitor system resources
htop  # or Task Manager on Windows

# Check disk space
df -h  # Linux/macOS
```

#### Weekly
- Review API response times
- Check database size and optimize
- Update sensor calibration if needed

```bash
# Optimize SQLite database
sqlite3 greenhouse.db "VACUUM;"

# Check database size
du -sh greenhouse.db
```

#### Monthly
- Update dependencies
- Review and rotate logs
- Backup database
- Check SSL certificate expiry

```bash
# Backend updates
pip list --outdated
pip install --upgrade <package>

# Frontend updates
flutter pub outdated
flutter pub upgrade
```

### Backup Strategy

#### Database Backup

```bash
# SQLite backup (automated)
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
sqlite3 greenhouse.db ".backup /backups/greenhouse_$DATE.db"

# Keep last 30 days
find /backups -name "greenhouse_*.db" -mtime +30 -delete

# Schedule with cron
# 0 2 * * * /path/to/backup-script.sh
```

#### Application Backup

```bash
# Git backup
git add .
git commit -m "Backup $(date +%Y-%m-%d)"
git push origin main

# Full system backup
tar -czf ecoview-backup-$(date +%Y%m%d).tar.gz \
    python_backend/ \
    flutter_frontend/ \
    .env \
    greenhouse.db
```

### Update Procedure

#### Backend Updates

```bash
# 1. Backup current version
cp -r python_backend python_backend.backup

# 2. Pull updates
git pull origin main

# 3. Update dependencies
pip install -r requirements.txt --upgrade

# 4. Test in development
python app.py

# 5. If successful, restart production
sudo systemctl restart ecoview-backend

# 6. Monitor logs
journalctl -u ecoview-backend -f
```

#### Frontend Updates

```bash
# 1. Update dependencies
flutter pub upgrade

# 2. Test on device
flutter run --release

# 3. Build new APK
flutter build apk --release

# 4. Version bump in pubspec.yaml
# version: 1.0.1+2  (version+build number)

# 5. Distribute updated APK
```

#### Hardware Updates

```bash
# OTA (Over-The-Air) Updates for ESP32

# Add to Arduino code:
#include <ArduinoOTA.h>

void setup() {
  // ... existing setup
  
  ArduinoOTA.setHostname("greenhouse-esp32");
  ArduinoOTA.setPassword("your-ota-password");
  ArduinoOTA.begin();
}

void loop() {
  ArduinoOTA.handle();
  // ... existing loop
}

# Update via Arduino IDE:
# Tools > Port > greenhouse-esp32 at <IP>
# Upload as normal
```

### Monitoring Setup

#### Application Monitoring

```python
# Add logging to app.py
import logging
from logging.handlers import RotatingFileHandler

handler = RotatingFileHandler(
    'app.log', 
    maxBytes=10000000,  # 10MB
    backupCount=5
)
handler.setLevel(logging.INFO)
app.logger.addHandler(handler)

# Log important events
app.logger.info(f"API call: {request.path}")
app.logger.error(f"Error: {str(e)}")
```

#### Server Monitoring

```bash
# Install monitoring tools
pip install flask-monitoring-dashboard

# Add to app.py
from flask_monitoringdashboard import Dashboard
Dashboard(app)

# Access at: http://localhost:5000/dashboard
```

#### Alerting Setup

```python
# Email alerts for critical errors
import smtplib
from email.mime.text import MIMEText

def send_alert(subject, message):
    msg = MIMEText(message)
    msg['Subject'] = subject
    msg['From'] = 'alerts@ecoview.com'
    msg['To'] = 'admin@ecoview.com'
    
    with smtplib.SMTP('smtp.gmail.com', 587) as server:
        server.starttls()
        server.login('user', 'password')
        server.send_message(msg)

# Trigger on critical conditions
if temperature > 35:
    send_alert('Critical Temperature', f'Temperature: {temperature}°C')
```

---

## Security Best Practices

### API Security

#### 1. Authentication (Recommended for Production)

```python
from functools import wraps
import jwt

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        
        if not token:
            return jsonify({'message': 'Token missing'}), 401
        
        try:
            data = jwt.decode(token, app.config['SECRET_KEY'], algorithms=["HS256"])
        except:
            return jsonify({'message': 'Token invalid'}), 401
        
        return f(*args, **kwargs)
    
    return decorated

@app.route('/readings/latest')
@token_required
def get_latest_readings():
    # Protected endpoint
    pass
```

#### 2. Rate Limiting

```python
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"]
)

@app.route('/ai-recommendations')
@limiter.limit("10 per minute")
def ai_recommendations():
    pass
```

#### 3. Input Validation

```python
from marshmallow import Schema, fields, validate

class SensorDataSchema(Schema):
    temperature = fields.Float(required=True, validate=validate.Range(min=-50, max=100))
    humidity = fields.Float(required=True, validate=validate.Range(min=0, max=100))
    # ... other fields

schema = SensorDataSchema()
errors = schema.validate(request_data)
if errors:
    return jsonify(errors), 400
```

#### 4. HTTPS Only

```python
# Force HTTPS in production
from flask_talisman import Talisman

if not app.debug:
    Talisman(app, force_https=True)
```

### Database Security

```python
# Use parameterized queries (already implemented)
cursor.execute("SELECT * FROM readings WHERE sensor_type = ?", (sensor_type,))

# Regular backups
# Encryption at rest (for sensitive data)
# Access control (limit database user permissions)
```

### Mobile App Security

```dart
// 1. Secure storage for sensitive data
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();
await storage.write(key: 'api_token', value: token);

// 2. Certificate pinning (HTTPS)
import 'package:http/io_client.dart';
import 'dart:io';

SecurityContext context = SecurityContext.defaultContext;
context.setTrustedCertificates('path/to/certificates.pem');

// 3. Code obfuscation (for release builds)
// Already enabled in: flutter build apk --release
```

### Network Security

```bash
# 1. Firewall rules
sudo ufw enable
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw allow 1883/tcp  # MQTT
sudo ufw deny 5000/tcp   # Block direct Flask access

# 2. Fail2ban for SSH protection
sudo apt-get install fail2ban

# 3. VPN for hardware (optional)
# Use WireGuard or OpenVPN for ESP32 connections
```

### Environment Variables

```bash
# Never commit secrets to Git
echo ".env" >> .gitignore

# Use strong secrets
SECRET_KEY=$(python -c 'import secrets; print(secrets.token_hex(32))')

# Rotate credentials regularly
# Store in secure vault (e.g., AWS Secrets Manager, Azure Key Vault)
```

### Compliance Checklist

- [ ] All API endpoints use HTTPS in production
- [ ] Authentication implemented for sensitive endpoints
- [ ] Rate limiting configured
- [ ] Input validation on all user inputs
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (output encoding)
- [ ] CORS properly configured (restrict origins)
- [ ] Secrets stored securely (not in code)
- [ ] Regular security updates applied
- [ ] Logging enabled (without logging sensitive data)
- [ ] Error messages don't expose system details
- [ ] Database backups encrypted
- [ ] User data anonymized in logs

---

## Performance Optimization

### Backend Optimization

```python
# 1. Database indexing
cursor.execute('''
    CREATE INDEX IF NOT EXISTS idx_timestamp 
    ON readings(timestamp DESC)
''')

# 2. Query optimization
# Use LIMIT for large datasets
cursor.execute('SELECT * FROM readings ORDER BY timestamp DESC LIMIT 1000')

# 3. Caching
from flask_caching import Cache

cache = Cache(app, config={'CACHE_TYPE': 'simple'})

@app.route('/readings/latest')
@cache.cached(timeout=5)  # Cache for 5 seconds
def get_latest_readings():
    pass

# 4. Compression
from flask_compress import Compress
Compress(app)
```

### Frontend Optimization

```dart
// 1. Lazy loading
ListView.builder(
  itemCount: data.length,
  itemBuilder: (context, index) {
    return ListTile(title: Text(data[index]));
  },
)

// 2. Image optimization
// Use cached_network_image package

// 3. State management
// Use Provider or Riverpod for efficient rebuilds

// 4. Bundle size optimization
flutter build apk --split-per-abi
```

### Hardware Optimization

```cpp
// 1. Power management
esp_sleep_enable_timer_wakeup(60 * 1000000); // Wake every minute
esp_light_sleep_start();

// 2. Reduce sampling rate
const long interval = 60000; // 1 minute instead of 5 seconds

// 3. Buffer data before sending
#define BUFFER_SIZE 10
float tempBuffer[BUFFER_SIZE];
int bufferIndex = 0;

// Send when buffer is full
if (bufferIndex >= BUFFER_SIZE) {
  sendBufferedData();
  bufferIndex = 0;
}
```

---

## Appendix

### A. Environment Variables Reference

| Variable | Description | Example | Required |
|----------|-------------|---------|----------|
| `GEMINI_API_KEY` | Google Gemini API key | `AIza...` | Yes |
| `MQTT_BROKER` | MQTT broker address | `192.168.1.100` | Yes |
| `MQTT_PORT` | MQTT broker port | `1883` | Yes |
| `MQTT_USERNAME` | MQTT username | `greenhouse_user` | No |
| `MQTT_PASSWORD` | MQTT password | `secure_pass` | No |
| `SECRET_KEY` | Flask secret key | Random hex string | Yes |
| `DATABASE_URL` | Database connection | `sqlite:///greenhouse.db` | Yes |
| `HOST` | Flask host | `0.0.0.0` | No |
| `PORT` | Flask port | `5000` | No |
| `DEBUG` | Debug mode | `False` | No |

### B. API Endpoints Reference

| Endpoint | Method | Description | Parameters |
|----------|--------|-------------|------------|
| `/readings/latest` | GET | Latest sensor data | None |
| `/readings/history/<type>/<range>` | GET | Historical data | `type`, `range` |
| `/ai-recommendations` | GET | AI advice | None |
| `/sensor-analysis/<type>/<range>` | GET | Detailed analysis | `type`, `range` |
| `/notifications` | GET | Get alerts | None |
| `/export-report` | GET | Generate PDF | None |

### C. Default Thresholds

| Sensor | Min | Optimal | Max | Unit |
|--------|-----|---------|-----|------|
| Temperature | 18 | 22 | 28 | °C |
| Humidity | 50 | 60 | 70 | % |
| CO2 | 400 | 800 | 1200 | ppm |
| Soil Moisture | 30 | 50 | 70 | % |
| Light | 2000 | 5000 | 8000 | lux |

### D. Useful Commands

```bash
# Backend
python app.py                      # Start server
pip freeze > requirements.txt      # Save dependencies
flask routes                       # List all routes
gunicorn --bind 0.0.0.0:5000 app:app  # Production server

# Frontend
flutter doctor                     # Check setup
flutter clean                      # Clean build
flutter pub get                    # Install dependencies
flutter build apk                  # Build APK
flutter analyze                    # Static analysis

# Git
git status                         # Check changes
git add .                          # Stage all
git commit -m "message"           # Commit
git push origin main              # Push to remote

# Database
sqlite3 greenhouse.db             # Open database
.tables                           # List tables
.schema readings                  # Show schema
SELECT * FROM readings LIMIT 10;  # Query data

# MQTT
mosquitto_sub -h <broker> -t "#" -v  # Subscribe all topics
mosquitto_pub -h <broker> -t test -m "hello"  # Publish message

# System
sudo systemctl status ecoview-backend  # Check service
journalctl -u ecoview-backend -f      # Follow logs
netstat -tulpn                        # Show ports
```

### E. Support & Resources

- **GitHub Repository**: https://github.com/Ismail-deb/sturdy-giggle
- **Flutter Documentation**: https://docs.flutter.dev
- **Flask Documentation**: https://flask.palletsprojects.com
- **Gemini API Docs**: https://ai.google.dev/docs
- **ESP32 Documentation**: https://docs.espressif.com
- **MQTT Protocol**: https://mqtt.org

### F. Glossary

- **APK**: Android Package Kit - Android app format
- **CORS**: Cross-Origin Resource Sharing - web security feature
- **DTH22**: Digital temperature and humidity sensor
- **MQTT**: Message Queuing Telemetry Transport - IoT protocol
- **OTA**: Over-The-Air - wireless updates
- **REST API**: Representational State Transfer API
- **SSL/TLS**: Secure Sockets Layer / Transport Layer Security
- **YAML**: YAML Ain't Markup Language - configuration format

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-11-02 | Initial deployment guide |

---

**Document Maintained By**: Development Team  
**Last Updated**: November 2, 2025  
**Next Review**: February 2, 2026
