# EcoView - Local Deployment Guide# EcoView - Local Deployment Guide



**Scope:** Single-network deployment for development, testing, and local monitoring only.**Scope:** Single-network deployment for development, testing, and local monitoring only.



## System Requirements## System Requirements



- **Backend:** Windows 10/11, macOS, or Linux; Python 3.10+; 100MB free space- **Backend:** Windows 10/11, macOS, or Linux; Python 3.10+; 100MB free space

- **Frontend:** Windows desktop, macOS, Linux, or Chrome web- **Frontend:** Windows desktop, macOS, Linux, or Chrome web

- **Network:** Devices on same WiFi network- **Network:** Devices on same WiFi network

- **APEX:** Access to Oracle APEX greenhouse data API- **APEX:** Access to Oracle APEX greenhouse data API



## Setup: Backend (Windows Example)## Setup: Backend (Windows Example)



1. **Install Python dependencies:**1. **Install Python dependencies:**

```powershell```powershell

cd python_backendcd python_backend

pip install flask flask-cors requests python-dotenv reportlab==4.4.4pip install flask flask-cors requests python-dotenv reportlab==4.4.4

``````



2. **Create `.env`:**2. **Create `.env`:**

``````

ORACLE_APEX_URL=https://oracleapex.com/ords/g3_data/iot/greenhouse/ORACLE_APEX_URL=https://oracleapex.com/ords/g3_data/iot/greenhouse/

GEMINI_API_KEY=sk-... # OptionalGEMINI_API_KEY=sk-... # Optional

``````



3. **Run:**3. **Run:**

```powershell```powershell

python app.pypython app.py

``````

- Backend listens on `0.0.0.0:5000` (all network interfaces)- Backend listens on `0.0.0.0:5000` (all network interfaces)

- Broadcasts to local network every 5 seconds: `GREENHOUSE_SERVER:<ip>:5000`- Broadcasts to local network every 5 seconds: `GREENHOUSE_SERVER:<ip>:5000`

- Polls APEX every 3 seconds- Polls APEX every 3 seconds



## Setup: Frontend## Setup: Frontend



**Option A: Chrome (Fastest for testing)****Option A: Chrome (Fastest for testing)**

```powershell```powershell

cd flutter_frontendcd flutter_frontend

flutter pub getflutter pub get

flutter run -d chromeflutter run -d chrome

``````



**Option B: Windows Desktop****Option B: Windows Desktop**

```powershell```powershell

flutter run -d windowsflutter run -d windows

``````



**Option C: Android APK****Option C: Android APK**

```powershell```powershell

flutter build apk --releaseflutter build apk --release

# Then sideload to device or run via Android Studio# Then sideload to device or run via Android Studio

``````



## Network Discovery## Network Discovery



The app auto-discovers the backend via UDP broadcast. To verify:The app auto-discovers the backend via UDP broadcast. To verify:



1. Backend running on local IP (e.g., `192.168.1.100`)1. Backend running on local IP (e.g., `192.168.1.100`)

2. Frontend on same network (same WiFi)2. Frontend on same network (same WiFi)

3. If auto-discovery fails, manually set IP in app Settings3. If auto-discovery fails, manually set IP in app Settings



**Check backend health:****Check backend health:**

``````

http://<backend-ip>:5000/api/healthhttp://<backend-ip>:5000/api/health

``````



## Useful Commands## Useful Commands



| Task | Command || Task | Command |

|------|---------||------|---------|

| Start backend | `cd python_backend; python app.py` || Start backend | `cd python_backend; python app.py` |

| Rebuild Flutter | `cd flutter_frontend; flutter pub get; flutter run -d chrome` || Rebuild Flutter | `cd flutter_frontend; flutter pub get; flutter run -d chrome` |

| Check backend logs | Watch terminal where `python app.py` runs || Check backend logs | Watch terminal where `python app.py` runs |

| Generate PDF report | Visit `/api/export-report` in browser after app runs || Generate PDF report | Visit `/api/export-report` in browser after app runs |

| Restart everything | Kill Python process, stop Flutter, run both again || Restart everything | Kill Python process, stop Flutter, run both again |



## Known Limitations## Known Limitations



- **No cloud:** Data stays on local network- **No cloud:** Data stays on local network

- **No authentication:** Works on trusted networks only- **No authentication:** Works on trusted networks only

- **Single user:** Not designed for concurrent users- **Single user:** Not designed for concurrent users

- **No VPN/remote:** Requires direct LAN access- **No VPN/remote:** Requires direct LAN access

- **Windows Firewall:** May block port 5000 (allow in firewall settings)- **Windows Firewall:** May block port 5000 (allow in firewall settings)

> 3. Deploy the backend on a cloud server (AWS, Azure, Google Cloud)

## Troubleshooting> 4. Configure firewall rules and security groups

> 5. Implement proper authentication and authorization

### Backend won't start> 6. Test thoroughly in production-like environments

- Verify Python is installed: `python --version`> 7. Follow app store guidelines if publishing to Google Play or Apple App Store

- Reinstall reportlab if issues: `pip install --upgrade reportlab==4.4.4`>

- Check port 5000 is free: `netstat -ano | findstr :5000`> **For Local/Development Use:**

> This guide focuses on local deployment for testing and development purposes, which is sufficient for:

### Frontend can't connect> - Academic projects and demonstrations

- Verify backend is running and reachable on same network> - Proof-of-concept implementations

- Check Windows Firewall allows port 5000> - Local greenhouse monitoring within a single network

- Manually set backend IP in app Settings if auto-discovery fails> - Development and debugging



### APEX data not loading---

- Verify ORACLE_APEX_URL in `.env` is correct

- Check internet connection (APEX must be reachable)---

- Look for errors in Flask terminal output

## System Requirements

## Next Steps

### Development Machine

See `README.md` for architecture and features, `USER_MANUAL.md` for app walkthrough.- **OS**: Windows 10/11, macOS 10.15+, or Linux (Ubuntu 20.04+)

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

Create `greenhouse_sensors.ino` with the complete production-ready code:

```cpp
/*
 * ============================================================================
 * UNIFIED GREENHOUSE SENSOR MONITORING SYSTEM - MQTT OUTPUT
 * ============================================================================
 * IFS325 Group Project - ARC Smart Agriculture
 * ESP32 Version - All Sensors with MQTT Publishing
 * 
 * SENSORS INTEGRATED:
 *   - BMP280: Barometric pressure, temperature, altitude
 *   - DHT22: Temperature and humidity
 *   - Flame Sensor: Fire detection (calibrated)
 *   - LDR: Ambient light measurement (calibrated)
 *   - MQ135: CO2 and air quality
 *   - MQ2: LPG and smoke detection
 *   - MQ7: Carbon monoxide detection
 * 
 * OUTPUT METHOD:
 *   - MQTT Publishing (Real-time streaming)
 * 
 * AUTHOR: ARC Smart Agriculture Team
 * VERSION: 3.2 - MQTT Only Edition
 * ============================================================================
 */

#include "Arduino.h"
#include <Wire.h>
#include <Adafruit_BMP280.h>
#include "DHT.h"
#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>

// ============================================================================
// CONFIGURATION SECTION - EDIT THESE VALUES
// ============================================================================

// WiFi Credentials
const char* WIFI_SSID = "YOUR_WIFI_SSID";
const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";

// MQTT Broker Configuration
const char* MQTT_BROKER = "YOUR_MQTT_BROKER_IP";
const int MQTT_PORT = 1883;
const char* MQTT_TOPIC = "greenhouse/sensors";
const char* MQTT_CLIENT_ID = "ESP32_Greenhouse_01";

// Enable/Disable MQTT Output
const bool ENABLE_MQTT = true;      // Set to false to disable MQTT

// ============================================================================
// PIN DEFINITIONS
// ============================================================================

#define FLAME_SENSOR_PIN 35
#define DHT_PIN 16
#define LDR_PIN 34
#define DHTTYPE DHT22

#define SDA_PIN 21
#define SCL_PIN 22

#define MQ135_PIN 32
#define MQ2_PIN 33
#define MQ7_PIN 39

// ============================================================================
// SENSOR OBJECT INITIALIZATION
// ============================================================================

Adafruit_BMP280 bmp;
DHT dht(DHT_PIN, DHTTYPE);
WiFiClient espClient;
PubSubClient mqttClient(espClient);

// ============================================================================
// CALIBRATION & THRESHOLD CONSTANTS
// ============================================================================

const float PRESSURE_NORMAL = 1013.25;
float baselinePressure = PRESSURE_NORMAL;
bool baselineSet = false;

// Flame sensor calibration
int FLAME_THRESHOLD = 1000;  // Raw < 1000 = flame detected
bool flame_calibrated = false;

// LDR calibration
int ldr_min = 0;
int ldr_max = 4095;
bool ldr_calibrated = false;

// Gas sensor baselines
int mq135_baseline = 0;
int mq2_baseline = 0;
int mq7_baseline = 0;
bool gas_sensors_calibrated = false;

// ============================================================================
// TIMING CONTROL
// ============================================================================

unsigned long lastReadTime = 0;
const long READ_INTERVAL = 10000;  // 10 seconds

unsigned long lastMqttReconnectAttempt = 0;
const long MQTT_RECONNECT_INTERVAL = 5000;

// ============================================================================
// SENSOR DATA STRUCTURE
// ============================================================================

struct SensorData {
  // Environmental readings
  float temp_bmp280;
  float temp_dht22;
  float pressure;
  float altitude;
  float humidity;
  
  // Analog sensor readings
  int flame_raw;
  int flame_detected;     // 1 = flame detected, 0 = no flame
  int light_raw;
  float light_percent;    // 0-100% brightness
  
  // Gas sensor readings
  int mq135_raw;
  int mq135_baseline;
  int mq135_drop;
  
  int mq2_raw;
  int mq2_baseline;
  int mq2_drop;
  
  int mq7_raw;
  int mq7_baseline;
  int mq7_drop;
  
  bool valid;
};

// ============================================================================
// SETUP FUNCTION
// ============================================================================

void setup() {
  Serial.begin(115200);
  delay(1000);
  
  printStartupBanner();
  
  // Initialize I2C
  Wire.begin(SDA_PIN, SCL_PIN);
  
  // Initialize BMP280
  if (!bmp.begin(0x76)) {
    if (!bmp.begin(0x77)) {
      Serial.println("❌ FATAL ERROR: BMP280 sensor not found!");
      while (1) delay(10);
    }
  }
  
  bmp.setSampling(Adafruit_BMP280::MODE_NORMAL,
                  Adafruit_BMP280::SAMPLING_X2,
                  Adafruit_BMP280::SAMPLING_X16,
                  Adafruit_BMP280::FILTER_X16,
                  Adafruit_BMP280::STANDBY_MS_500);
  Serial.println("✓ BMP280 initialized successfully");
  
  // Initialize DHT22
  dht.begin();
  Serial.println("✓ DHT22 initialized successfully");
  
  // Configure analog pins
  pinMode(FLAME_SENSOR_PIN, INPUT);
  pinMode(LDR_PIN, INPUT);
  pinMode(MQ135_PIN, INPUT);
  pinMode(MQ2_PIN, INPUT);
  pinMode(MQ7_PIN, INPUT);
  Serial.println("✓ Analog sensor pins configured");
  
  // Connect to WiFi
  connectToWiFi();
  
  // Configure MQTT if enabled
  if (ENABLE_MQTT) {
    mqttClient.setServer(MQTT_BROKER, MQTT_PORT);
    mqttClient.setBufferSize(1024);
    Serial.println("✓ MQTT client configured (buffer: 1024 bytes)");
    reconnectMqtt();
  }
  
  // Calibrate flame sensor
  calibrateFlame();
  
  // Calibrate LDR
  calibrateLDR();
  
  // Calibrate gas sensors
  calibrateGasSensors();
  
  Serial.println("\n╔══════════════════════════════════════════════════════╗");
  Serial.println("║     INITIALIZATION COMPLETE - MONITORING STARTED     ║");
  Serial.println("╚══════════════════════════════════════════════════════╝\n");
  
  printOutputStatus();
}

// ============================================================================
// MAIN LOOP
// ============================================================================

void loop() {
  // Check WiFi connection
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("⚠ WiFi disconnected. Attempting reconnection...");
    connectToWiFi();
  }
  
  // Maintain MQTT connection if enabled
  if (ENABLE_MQTT) {
    if (!mqttClient.connected()) {
      unsigned long now = millis();
      if (now - lastMqttReconnectAttempt > MQTT_RECONNECT_INTERVAL) {
        lastMqttReconnectAttempt = now;
        reconnectMqtt();
      }
    } else {
      mqttClient.loop();
    }
  }
  
  // Read and publish sensor data at intervals
  unsigned long currentTime = millis();
  if (currentTime - lastReadTime >= READ_INTERVAL) {
    lastReadTime = currentTime;
    
    printCycleHeader(currentTime);
    
    // Read all sensors
    SensorData data = readAllSensors();
    
    if (data.valid) {
      // Publish to MQTT if enabled
      if (ENABLE_MQTT && mqttClient.connected()) {
        publishMqttMessage(data);
      }
    } else {
      Serial.println("❌ Sensor data invalid - skipping transmission");
    }
    
    Serial.println("\n════════════════════════════════════════════════════════\n");
  }
  
  delay(10);
}

// ============================================================================
// WIFI CONNECTION FUNCTION
// ============================================================================

void connectToWiFi() {
  Serial.print("Connecting to WiFi: ");
  Serial.print(WIFI_SSID);
  
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n✓ WiFi connected successfully");
    Serial.print("   IP Address: ");
    Serial.println(WiFi.localIP());
    Serial.print("   Signal Strength: ");
    Serial.print(WiFi.RSSI());
    Serial.println(" dBm");
  } else {
    Serial.println("\n❌ WiFi connection failed - will retry");
  }
}

// ============================================================================
// MQTT RECONNECTION FUNCTION
// ============================================================================

void reconnectMqtt() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("⚠ Cannot connect to MQTT - WiFi not available");
    return;
  }
  
  Serial.print("Attempting MQTT connection to ");
  Serial.print(MQTT_BROKER);
  Serial.print(":");
  Serial.print(MQTT_PORT);
  Serial.print(" ... ");
  
  if (mqttClient.connect(MQTT_CLIENT_ID)) {
    Serial.println("✓ Connected!");
    Serial.print("   Client ID: ");
    Serial.println(MQTT_CLIENT_ID);
    Serial.print("   Publishing to: ");
    Serial.println(MQTT_TOPIC);
  } else {
    Serial.print("❌ Failed, rc=");
    Serial.println(mqttClient.state());
  }
}

// ============================================================================
// FLAME SENSOR CALIBRATION
// ============================================================================

void calibrateFlame() {
  Serial.println("\n╔══════════════════════════════════════════════════════╗");
  Serial.println("║          FLAME SENSOR CALIBRATION                    ║");
  Serial.println("╚══════════════════════════════════════════════════════╝");
  Serial.println("🔥 Calibrating flame sensor...");
  Serial.println("   Ensure NO flames are present during calibration");
  delay(2000);
  
  long sum = 0;
  int samples = 30;
  
  Serial.println("   Taking 30 samples...");
  for (int i = 0; i < samples; i++) {
    sum += analogRead(FLAME_SENSOR_PIN);
    delay(50);
  }
  
  int ambient_baseline = sum / samples;
  
  Serial.print("   Ambient baseline: ");
  Serial.println(ambient_baseline);
  Serial.println("   Threshold: 1000 ADC units");
  Serial.println("   Logic: Raw < 1000 = FLAME DETECTED");
  Serial.println("          Raw ≥ 1000 = NO FLAME");
  Serial.println("   ✓ Flame sensor ready\n");
  
  flame_calibrated = true;
}

// ============================================================================
// LDR CALIBRATION
// ============================================================================

void calibrateLDR() {
  Serial.println("╔══════════════════════════════════════════════════════╗");
  Serial.println("║          LDR (LIGHT SENSOR) CALIBRATION              ║");
  Serial.println("╚══════════════════════════════════════════════════════╝");
  Serial.println("💡 Measuring ambient light range...");
  delay(2000);
  
  int minVal = 4095;
  int maxVal = 0;
  int samples = 50;
  
  Serial.println("   Sampling for 2.5 seconds...");
  for (int i = 0; i < samples; i++) {
    int reading = analogRead(LDR_PIN);
    if (reading < minVal) minVal = reading;
    if (reading > maxVal) maxVal = reading;
    delay(50);
  }
  
  ldr_min = max(0, minVal - 100);
  ldr_max = min(4095, maxVal + 100);
  ldr_calibrated = true;
  
  Serial.print("   LDR range: ");
  Serial.print(ldr_min);
  Serial.print(" - ");
  Serial.println(ldr_max);
  Serial.println("   ✓ LDR calibrated\n");
}

// ============================================================================
// GAS SENSOR CALIBRATION
// ============================================================================

void calibrateGasSensors() {
  Serial.println("\n╔══════════════════════════════════════════════════════╗");
  Serial.println("║           GAS SENSOR CALIBRATION PHASE               ║");
  Serial.println("╚══════════════════════════════════════════════════════╝");
  Serial.println("⚠ IMPORTANT: Ensure all gas sensors are in CLEAN AIR");
  Serial.println("\nWarming up sensors for 300 seconds (5 minutes)...\n");
  
  for (int i = 300; i > 0; i--) {
    if (i % 30 == 0) {
      Serial.print("⏱ Warm-up countdown: ");
      Serial.print(i);
      Serial.println(" seconds remaining...");
    }
    delay(1000);
  }
  
  Serial.println("\nTaking baseline readings in clean air...");
  
  long sum135 = 0, sum2 = 0, sum7 = 0;
  const int samples = 50;
  
  for (int i = 0; i < samples; i++) {
    sum135 += analogRead(MQ135_PIN);
    sum2 += analogRead(MQ2_PIN);
    sum7 += analogRead(MQ7_PIN);
    delay(50);
  }
  
  mq135_baseline = sum135 / samples;
  mq2_baseline = sum2 / samples;
  mq7_baseline = sum7 / samples;
  gas_sensors_calibrated = true;
  
  Serial.println("\n✓ CALIBRATION COMPLETE");
  Serial.print("   MQ135 Baseline: ");
  Serial.println(mq135_baseline);
  Serial.print("   MQ2 Baseline: ");
  Serial.println(mq2_baseline);
  Serial.print("   MQ7 Baseline: ");
  Serial.println(mq7_baseline);
  Serial.println();
}

// ============================================================================
// READ ALL SENSORS FUNCTION
// ============================================================================

SensorData readAllSensors() {
  SensorData data;
  data.valid = true;
  
  // ---- BMP280 READINGS ----
  data.temp_bmp280 = bmp.readTemperature();
  data.pressure = bmp.readPressure() / 100.0F;
  
  if (!baselineSet) {
    baselinePressure = data.pressure;
    baselineSet = true;
  }
  
  data.altitude = bmp.readAltitude(baselinePressure);
  
  Serial.println("🌍 BAROMETRIC PRESSURE (BMP280)");
  Serial.print("   Temperature: ");
  Serial.print(data.temp_bmp280, 1);
  Serial.println(" °C");
  Serial.print("   Pressure: ");
  Serial.print(data.pressure, 2);
  Serial.println(" hPa");
  Serial.print("   Altitude: ");
  Serial.print(data.altitude, 1);
  Serial.println(" m");
  
  // ---- DHT22 READINGS ----
  data.humidity = dht.readHumidity();
  data.temp_dht22 = dht.readTemperature();
  
  if (isnan(data.humidity) || isnan(data.temp_dht22)) {
    Serial.println("💧 TEMPERATURE & HUMIDITY (DHT22)");
    Serial.println("   ❌ Sensor read error!");
    data.valid = false;
    return data;
  }
  
  Serial.println("💧 TEMPERATURE & HUMIDITY (DHT22)");
  Serial.print("   Temperature: ");
  Serial.print(data.temp_dht22, 1);
  Serial.println(" °C");
  Serial.print("   Humidity: ");
  Serial.print(data.humidity, 1);
  Serial.println(" %");
  
  // ---- FLAME SENSOR ----
  data.flame_raw = analogRead(FLAME_SENSOR_PIN);
  
  // FLAME DETECTION LOGIC: Raw < 1000 = FLAME DETECTED
  if (data.flame_raw < FLAME_THRESHOLD) {
    data.flame_detected = 1;  // Flame detected
  } else {
    data.flame_detected = 0;  // No flame
  }
  
  Serial.println("🔥 FLAME DETECTION SENSOR");
  Serial.print("   Raw Value: ");
  Serial.print(data.flame_raw);
  Serial.print(" (Threshold: ");
  Serial.print(FLAME_THRESHOLD);
  Serial.println(")");
  Serial.print("   Status: ");
  if (data.flame_detected == 1) {
    Serial.println("⚠⚠ FLAME DETECTED ⚠⚠");
  } else {
    Serial.println("✓ No flame detected");
  }
  
  // ---- LIGHT SENSOR (LDR) ----
  data.light_raw = analogRead(LDR_PIN);
  
  // Calculate brightness percentage
  if (ldr_calibrated) {
    data.light_percent = map(data.light_raw, ldr_min, ldr_max, 100, 0);
    data.light_percent = constrain(data.light_percent, 0, 100);
  } else {
    data.light_percent = map(data.light_raw, 0, 4095, 100, 0);
    data.light_percent = constrain(data.light_percent, 0, 100);
  }
  
  Serial.println("💡 AMBIENT LIGHT SENSOR (LDR)");
  Serial.print("   Raw Value: ");
  Serial.print(data.light_raw);
  Serial.print(" (");
  Serial.print(data.light_percent, 1);
  Serial.println("% brightness)");
  
  // ---- MQ135 GAS SENSOR ----
  data.mq135_raw = analogRead(MQ135_PIN);
  data.mq135_baseline = mq135_baseline;
  data.mq135_drop = data.mq135_raw - mq135_baseline;
  
  Serial.println("🌫️  MQ135 - CO2/AIR QUALITY");
  Serial.print("   Raw: ");
  Serial.print(data.mq135_raw);
  Serial.print(" | Baseline: ");
  Serial.print(data.mq135_baseline);
  Serial.print(" | Drop: ");
  Serial.println(data.mq135_drop);
  
  // ---- MQ2 GAS SENSOR ----
  data.mq2_raw = analogRead(MQ2_PIN);
  data.mq2_baseline = mq2_baseline;
  data.mq2_drop = data.mq2_raw - mq2_baseline;
  
  Serial.println("💨 MQ2 - LPG/SMOKE DETECTION");
  Serial.print("   Raw: ");
  Serial.print(data.mq2_raw);
  Serial.print(" | Baseline: ");
  Serial.print(data.mq2_baseline);
  Serial.print(" | Drop: ");
  Serial.println(data.mq2_drop);
  
  // ---- MQ7 GAS SENSOR ----
  data.mq7_raw = analogRead(MQ7_PIN);
  data.mq7_baseline = mq7_baseline;
  data.mq7_drop = data.mq7_raw - mq7_baseline;
  
  Serial.println("☠️  MQ7 - CARBON MONOXIDE (CO)");
  Serial.print("   Raw: ");
  Serial.print(data.mq7_raw);
  Serial.print(" | Baseline: ");
  Serial.print(data.mq7_baseline);
  Serial.print(" | Drop: ");
  Serial.println(data.mq7_drop);
  
  return data;
}

// ============================================================================
// PUBLISH TO MQTT
// ============================================================================

void publishMqttMessage(SensorData data) {
  JsonDocument doc;
  
  doc["temperature_bmp280"] = round(data.temp_bmp280 * 100) / 100.0;
  doc["temperature_dht22"] = round(data.temp_dht22 * 100) / 100.0;
  doc["pressure"] = round(data.pressure * 100) / 100.0;
  doc["altitude"] = round(data.altitude * 100) / 100.0;
  doc["humidity"] = round(data.humidity * 100) / 100.0;
  
  doc["flame_raw"] = data.flame_raw;
  doc["flame_detected"] = data.flame_detected;
  doc["light_raw"] = data.light_raw;
  doc["light_percent"] = round(data.light_percent * 100) / 100.0;
  
  doc["mq135_raw"] = data.mq135_raw;
  doc["mq135_baseline"] = data.mq135_baseline;
  doc["mq135_drop"] = data.mq135_drop;
  
  doc["mq2_raw"] = data.mq2_raw;
  doc["mq2_baseline"] = data.mq2_baseline;
  doc["mq2_drop"] = data.mq2_drop;
  
  doc["mq7_raw"] = data.mq7_raw;
  doc["mq7_baseline"] = data.mq7_baseline;
  doc["mq7_drop"] = data.mq7_drop;
  
  String jsonString;
  serializeJson(doc, jsonString);
  
  Serial.println("\n📤 MQTT PUBLISH:");
  Serial.println(jsonString);
  Serial.print("   Size: ");
  Serial.print(jsonString.length());
  Serial.println(" bytes");
  
  if (mqttClient.publish(MQTT_TOPIC, jsonString.c_str())) {
    Serial.println("   ✓ Successfully published to MQTT broker");
  } else {
    Serial.println("   ❌ MQTT publish failed");
  }
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

void printStartupBanner() {
  Serial.println("\n\n╔══════════════════════════════════════════════════════╗");
  Serial.println("║   GREENHOUSE SENSOR SYSTEM - MQTT EDITION           ║");
  Serial.println("║   IFS325 Group Project - ARC Smart Agriculture       ║");
  Serial.println("║   Version 3.2 - MQTT Only Edition                    ║");
  Serial.println("╚══════════════════════════════════════════════════════╝\n");
}

void printCycleHeader(unsigned long currentTime) {
  Serial.println("\n╔══════════════════════════════════════════════════════╗");
  Serial.println("║              SENSOR READING CYCLE                    ║");
  Serial.print("║ Uptime: ");
  Serial.print(currentTime / 1000);
  Serial.println(" seconds                                  ║");
  Serial.println("╚══════════════════════════════════════════════════════╝\n");
}

void printOutputStatus() {
  Serial.println("\n╔══════════════════════════════════════════════════════╗");
  Serial.println("║              OUTPUT CONFIGURATION                    ║");
  Serial.println("╚══════════════════════════════════════════════════════╝");
  Serial.print("   MQTT Publishing: ");
  Serial.println(ENABLE_MQTT ? "ENABLED ✓" : "DISABLED ✗");
  Serial.println();
}
```

**Key Features of This Code:**
- ✅ Complete sensor integration (BMP280, DHT22, Flame, LDR, MQ135, MQ2, MQ7)
- ✅ Automatic sensor calibration on startup
- ✅ Robust WiFi and MQTT reconnection handling
- ✅ Detailed serial output for debugging
- ✅ JSON message formatting for backend compatibility
- ✅ Configurable read intervals and thresholds
- ✅ Production-ready error handling

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
