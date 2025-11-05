
# EcoView Greenhouse Monitoring System
## Complete User Manual & Deployment Guide

---

## Table of Contents

1. [Introduction](#introduction)
2. [System Overview](#system-overview)
3. [Getting Started](#getting-started)
4. [Installation Guide](#installation-guide)
5. [Application Interface](#application-interface)
6. [Core Features](#core-features)
7. [Troubleshooting Guide](#troubleshooting-guide)
8. [Best Practices](#best-practices)
9. [FAQ](#faq)
10. [Appendix](#appendix)

---

## Introduction

### What is EcoView?

EcoView is an intelligent greenhouse monitoring system that provides real-time environmental tracking through a **Flutter mobile application** and a **Python Flask backend**. It continuously monitors critical greenhouse parameters to help you maintain optimal growing conditions.

**Current Deployment Scope**: 
- ✅ Local WiFi networks (same physical location)
- ✅ Direct APK installation on Android devices
- ✅ Windows, macOS, and Linux desktop environments
- ✅ Development and testing scenarios

**Not Suitable For** (without modifications):
- ❌ Cloud deployment without additional security
- ❌ Public internet access (requires SSL/TLS)
- ❌ App store distribution (as-is)

### Key Capabilities

- **8-Sensor Real-Time Monitoring**: Temperature, humidity, soil moisture, light, CO2, air quality, smoke, flame
- **Auto-Discovery**: Frontend automatically finds backend on local network via UDP broadcast
- **Historical Analysis**: Track trends across minutes, hours, days, months, and years
- **AI Recommendations**: Google Gemini-powered insights (with fallback guidance)
- **PDF Reports**: Generate comprehensive documentation of greenhouse conditions
- **Instant Alerts**: Critical, warning, and informational notifications
- **Cross-Platform**: Works on Windows, macOS, Linux desktop and Android mobile

---

## System Overview

### Architecture

```
┌────────────────────────────────────────────────────┐
│           ECOVIEW SYSTEM ARCHITECTURE               │
├────────────────────────────────────────────────────┤
│                                                     │
│  Flutter Application (Cross-Platform UI)           │
│  ├─ Dashboard: Real-time sensor monitoring        │
│  ├─ Sensor Analysis: Historical trends            │
│  ├─ AI Recommendations: Automated guidance        │
│  └─ Report Export: PDF generation                 │
│           │                                         │
│           │ HTTP REST API (Port 5000)              │
│           ↓                                         │
│  ┌──────────────────────────────┐                 │
│  │   Flask Backend (Python)      │                 │
│  │  ├─ Sensor aggregation        │                 │
│  │  ├─ APEX polling (10s interval)│                │
│  │  ├─ AI integration (Gemini)   │                 │
│  │  ├─ PDF generation            │                 │
│  │  └─ UDP broadcast discovery   │                 │
│  └──────────────────────────────┘                 │
│           │                                         │
│           │ REST API calls                         │
│           ↓                                         │
│  Oracle APEX Database                              │
│  └─ Live sensor readings & history                 │
│                                                     │
└────────────────────────────────────────────────────┘
```

### Technology Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Frontend** | Flutter (Dart) | Cross-platform UI for monitoring |
| **Backend** | Python 3.10+ Flask | REST API & data aggregation |
| **Database** | Oracle APEX | Sensor data storage & retrieval |
| **AI Engine** | Google Gemini API | Intelligent recommendations |
| **Discovery** | UDP Broadcast | Network auto-discovery |
| **Reports** | ReportLab | PDF generation |

---

## Getting Started

### System Requirements

#### Desktop/Laptop (Backend Server)
- **OS**: Windows 10+, Ubuntu 20.04+, macOS 10.15+
- **CPU**: 2 cores minimum
- **RAM**: 4GB (2GB minimum)
- **Storage**: 5GB free space
- **Python**: 3.10 or higher
- **Network**: Static or reserved IP preferred

#### Mobile Device (Frontend)
- **Android**: Version 7.0+ (API 24+) recommended
- **iOS**: Version 12.0+ (if available)
- **Storage**: 100MB free space
- **RAM**: 2GB minimum
- **Network**: WiFi capable

#### Desktop Frontend (Windows/macOS/Linux)
- **RAM**: 8GB minimum (16GB recommended)
- **Storage**: 5GB free space
- **Flutter SDK**: 3.x
- **Network**: WiFi or Ethernet

### Pre-Deployment Checklist

- [ ] Python 3.10+ installed and in system PATH
- [ ] All dependencies from `requirements.txt` can be installed
- [ ] Virtual environment creation support available
- [ ] `.env` file configuration template created
- [ ] Oracle APEX endpoint verified and accessible
- [ ] Google Gemini API key obtained (optional)
- [ ] Network firewall configured to allow port 5000
- [ ] All devices can be on same WiFi network
- [ ] Backend machine has static/reserved IP or hostname

---

## Installation Guide

### Backend Installation (Windows)

#### Step 1: Clone Repository
```powershell
git clone https://github.com/Ismail-deb/sturdy-giggle.git
cd sturdy-giggle/python_backend
```

#### Step 2: Create Virtual Environment
```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1

# If execution policy error occurs:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.venv\Scripts\Activate.ps1
```

#### Step 3: Install Dependencies
```powershell
pip install --upgrade pip
pip install -r requirements.txt
```

**Verify installation:**
```powershell
pip list
```

Expected packages:
- Flask 2.3.x
- flask-cors 3.x.x
- paho-mqtt 1.x.x
- reportlab 3.x.x
- google-generativeai 0.x.x
- requests 2.x.x
- python-dotenv 0.x.x

#### Step 4: Configure Environment Variables

Create `.env` file in `python_backend/` directory:

```
FLASK_APP=app.py
FLASK_ENV=development
SECRET_KEY=your-random-secret-key-change-this

# Oracle APEX Configuration
ORACLE_APEX_URL=https://oracleapex.com/ords/g3_data/iot/greenhouse/

# Optional: Google Gemini AI
GEMINI_API_KEY=your-api-key-here

# Server Configuration
HOST=0.0.0.0
PORT=5000
DEBUG=True
```

**Important**: Never commit `.env` to Git. It's in `.gitignore`.

#### Step 5: Start Backend Server

```powershell
# Ensure virtual environment is activated
python app.py
```

**Expected output:**
```
 * Serving Flask app 'app'
 * Debug mode: on
 * Running on http://0.0.0.0:5000
 * WARNING: This is a development server.
```

#### Step 6: Verify Backend is Running

```powershell
# Test health endpoint
curl http://localhost:5000/api/health

# Expected response:
# {"status":"healthy","timestamp":"2025-11-05T07:23:58Z"}
```

### Backend Installation (Linux/Ubuntu)

#### Steps 1-3: Same as Windows
```bash
git clone https://github.com/Ismail-deb/sturdy-giggle.git
cd sturdy-giggle/python_backend
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

#### Steps 4-6: Same as Windows
```bash
python app.py
```

### Frontend Installation (Flutter)

#### Step 1: Setup Flutter Project
```bash
cd flutter_frontend
flutter pub get
flutter doctor
```

#### Step 2: Configure API Connection

Edit `lib/services/api_service.dart`:

**For Local Network:**
```dart
class ApiService {
  static const String baseUrl = 'http://192.168.1.X:5000';
  // Replace X with your backend server's IP address
}
```

#### Step 3: Run on Desktop

**Windows:**
```bash
flutter run -d windows
```

**macOS:**
```bash
flutter run -d macos
```

**Linux:**
```bash
flutter run -d linux
```

**Chrome Web:**
```bash
flutter run -d chrome
```

#### Step 4: Build Android APK

```bash
flutter clean
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### Step 5: Install on Android Device

```bash
adb install build/app/outputs/flutter-apk/app-release.apk

# Or use:
flutter install --release
```

---

## Application Interface

### [SCREENSHOT PLACEHOLDER 1: Dashboard Screen]
*Insert screenshot of main dashboard here*

### Dashboard Overview

The Dashboard is your main monitoring interface displaying real-time sensor data.

#### Dashboard Layout
```
┌─────────────────────────────────────────────┐
│  EcoView Dashboard                           │
│  Last Updated: 2:45 PM (Auto-refresh: 30s) │
├─────────────────────────────────────────────┤
│                                              │
│  ┌──────────────┐  ┌──────────────┐        │
│  │🌡️ Temperature│  │💧 Humidity   │        │
│  │ 23.5°C       │  │ 58%          │        │
│  │🟢 Optimal    │  │🟢 Optimal    │        │
│  └──────────────┘  └──────────────┘        │
│                                              │
│  ┌──────────────┐  ┌──────────────┐        │
│  │🌱 Soil Moist │  │☀️ Light      │        │
│  │ 45%          │  │ 2100 raw     │        │
│  │🟢 Optimal    │  │🟡 Moderate   │        │
│  └──────────────┘  └──────────────┘        │
│                                              │
│  ┌──────────────┐  ┌──────────────┐        │
│  │🌫️ Air Quality│  │🔥 Flame      │        │
│  │ 180 ppm      │  │ No flame     │        │
│  │🟢 Good       │  │🟢 Safe       │        │
│  └──────────────┘  └──────────────┘        │
│                                              │
├─────────────────────────────────────────────┤
│ [🤖 AI Recommendations] [📄 Export Report] │
│ [ℹ️ Sensor Info] [⚙️ Settings]             │
└─────────────────────────────────────────────┘
```

#### Sensor Card Components

Each card displays:

1. **Sensor Icon**: Visual representation (thermometer, water drop, etc.)
2. **Sensor Name**: Type of measurement
3. **Current Value**: Latest reading with units
4. **Status Badge**:
   - 🟢 **Green** = Optimal range
   - 🟡 **Yellow** = Warning (acceptable but not ideal)
   - 🔴 **Red** = Critical (immediate action needed)
5. **Trend Indicator**: 
   - ↑ = Increasing
   - ↓ = Decreasing
   - → = Stable

### [SCREENSHOT PLACEHOLDER 2: Sensor Analysis Screen]
*Insert screenshot of sensor details and trends here*

### Sensor Analysis Screen

Tap any sensor card to access detailed analysis:

#### Features

**1. Historical Chart**
- Default view: Last 24 hours
- Interactive: Tap points for exact values
- Chart types: Line, Bar, or Area
- Color-coded zones: Green (optimal), Yellow (warning), Red (critical)

**2. Time Range Selector**
Available options:
- Last Minute (5-second intervals)
- Last Hour (1-minute intervals)
- Last Day (hourly intervals)
- Last Week (daily intervals)
- Last Month (daily intervals)
- Last Year (weekly/monthly intervals)

**3. Statistics Panel**
```
Maximum:    28.5°C (2:30 PM)
Minimum:    19.2°C (5:00 AM)
Average:    23.8°C
Current:    23.5°C
Range:      9.3°C
```

**4. AI Insights**
- Pattern recognition
- Anomaly detection
- Contextual recommendations
- Fallback guidance if AI unavailable

### [SCREENSHOT PLACEHOLDER 3: AI Recommendations Screen]
*Insert screenshot of recommendations here*

### AI Recommendations

Access from Dashboard or tap "🤖 AI Recommendations" button.

#### Recommendation Priority Levels

**🔴 High Priority** (Red Badge)
- **When**: Values in critical range
- **Action**: Immediate intervention required
- **Examples**:
  - Temperature > 30°C or < 18°C
  - Humidity < 45% or > 80%
  - Flame detected
  - Soil moisture < 30%

**🟡 Medium Priority** (Yellow Badge)
- **When**: Values in warning range
- **Action**: Address within 24 hours
- **Examples**:
  - Temperature 27-30°C or 18-20°C
  - Humidity 45-50% or 70-80%
  - CO2 > 1000 ppm

**🟢 Low Priority** (Green Badge)
- **When**: Minor optimizations available
- **Action**: Consider when convenient
- **Examples**:
  - Fine-tuning for better growth
  - Seasonal adjustments
  - Energy efficiency tips

#### Example Recommendation Card
```
┌────────────────────────────────────────┐
│ 🌡️ TEMPERATURE MANAGEMENT              │
│ 🔴 High Priority                       │
│                                         │
│ "Temperature exceeding optimal range   │
│ during afternoon hours"                │
│                                         │
│ Recommended Actions:                   │
│ ✓ Increase ventilation (30-50 CFM)     │
│ ✓ Add shade cloth to reduce heat       │
│ ✓ Monitor afternoon peaks closely      │
│ ✓ Consider evaporative cooling         │
│                                         │
│ Expected Impact: 2-3°C temperature     │
│ reduction within 2 hours               │
└────────────────────────────────────────┘
```

### [SCREENSHOT PLACEHOLDER 4: Settings Screen]
*Insert screenshot of settings configuration here*

### Settings Screen

Configure application behavior and backend connection:

#### Available Settings

**Server Connection**
- Server IP: Manual backend address (e.g., 192.168.1.100)
- Port: Backend port (default: 5000)
- Auto-Discovery: Enable/disable automatic detection

**Application**
- Refresh Interval: Data update frequency (default: 30 seconds)
- Theme: Light/Dark mode
- Notifications: Alert preferences

**Display**
- Units: Celsius/Fahrenheit toggle
- Gas units: PPM display format
- Data points per chart: 50-500 points

#### Connection Status Display
```
Backend Status:
Connected to: 192.168.1.100:5000
Status: ✓ Online
Response Time: 45ms
Last Sync: 2:45 PM
Data Points: 2,847
APEX Connection: ✓ Active
```

---

## Core Features

### 1. Real-Time Monitoring

**Auto-Refresh Behavior**
- Dashboard updates automatically every 30 seconds
- Pull down gesture for manual refresh
- Tap refresh icon for immediate update
- Connection indicator shows sync status

**Status Indicators Explained**
- 🟢 **Green**: Within optimal operating parameters
- 🟡 **Yellow**: Outside optimal but acceptable
- 🔴 **Red**: Critical - immediate attention required

### 2. [SCREENSHOT PLACEHOLDER 5: Alert Notification]
*Insert screenshot of alert/notification example*

### Alert System

#### Critical Alerts (Red - Urgent)
Triggered when:
- Temperature > 30°C or < 18°C
- Humidity < 45% or > 80%
- Flame detected
- Soil moisture < 30%

**Response**: Immediate action required

#### Warning Alerts (Yellow - Important)
Triggered when:
- Values approaching critical thresholds
- Unusual rate of change detected
- Sensor connection issues

**Response**: Address within 24 hours

#### Info Notifications (Blue - Informational)
- New AI recommendations available
- System updates
- General tips and advice

### 3. Historical Trending

View data across multiple time periods to identify patterns:

**Time Range Analysis**
- **Last Minute**: Real-time 5-second updates
- **Last Hour**: Hourly trends, minute-level detail
- **Last Day**: 24-hour cycles, hourly data points
- **Last Week**: 7-day patterns, daily aggregates
- **Last Month**: 30-day trends, daily values
- **Last Year**: 12-month patterns, weekly aggregates

### 4. PDF Report Export

#### How to Generate Reports

1. Dashboard → Tap "📄 Export Report"
2. Wait for generation (10-30 seconds)
3. Choose: Open, Share, or Save
4. File saved to: `Downloads/greenhouse_report_YYYY-MM-DD.pdf`

#### Report Contents

**Page 1: Cover & Summary**
- Report title and date
- Greenhouse name (if configured)
- Overall status indicator

**Page 2: Current Conditions**
```
CURRENT READINGS SUMMARY

Temperature:    23.5°C    ✓ Optimal
Humidity:       58%       ✓ Optimal  
Soil Moisture:  45%       ✓ Optimal
Light:          2100 raw  ⚠ Moderate
Air Quality:    180 ppm   ✓ Good
Smoke:          120 ppm   ✓ Safe
CO:             45 ppm    ✓ Safe
Flame:          None      ✓ Safe

Overall Status: HEALTHY
Last Updated: 2:45 PM
```

**Pages 3-4: Detailed Statistics**
- For each sensor: Current, Max, Min, Average
- 24-hour and 7-day summaries
- Status indicators

**Pages 5-6: Historical Data Tables**
```
Timestamp    │ Temp │ Humid │ Light │ Soil
─────────────┼──────┼───────┼───────┼─────
10:00 AM     │ 22.1 │  59   │ 1900  │ 46
11:00 AM     │ 23.5 │  57   │ 2100  │ 45
12:00 PM     │ 24.8 │  55   │ 2800  │ 44
1:00 PM      │ 25.2 │  54   │ 3200  │ 43
```

**Pages 7-8: Charts and Visualizations**
- Temperature trend chart
- Humidity trend chart
- Light intensity chart
- Soil moisture chart

**Pages 9-10: AI Recommendations**
- Detailed analysis by sensor
- Prioritized action items
- Expected outcomes

**Pages 11-12: Appendix**
- Sensor specifications
- Optimal ranges reference
- Troubleshooting guide
- Contact information

### 5. Server Auto-Discovery

The app automatically finds the backend on your local network:

**How It Works**
1. Flask backend broadcasts `GREENHOUSE_SERVER:<ip>:5000` via UDP every 5 seconds
2. Flutter app listens for UDP packets on port 5000
3. When found, app automatically connects
4. Connection IP cached in device storage

**If Auto-Discovery Fails**
1. Settings → Server IP → Manual Entry
2. Enter backend IP: `192.168.1.X` or hostname
3. Enter port: `5000` (or custom)
4. Tap Connect
5. App should immediately show data

---

## Troubleshooting Guide

### Issue 1: App Cannot Connect to Backend

#### Symptoms
```
"Connection Failed"
"Unable to reach server"
"Connection timeout"
"Backend not found"
```

#### Diagnosis

**Step 1: Verify Backend is Running**
```powershell
# On the backend machine
curl http://localhost:5000/api/health

# Should return:
# {"status":"healthy","timestamp":"2025-11-05T07:23:58Z"}
```

**Step 2: Verify Same Network**
```
Check BOTH devices:
- Backend machine WiFi SSID
- Mobile/Desktop app WiFi SSID
- MUST be IDENTICAL network
```

**Step 3: Check Firewall**
```
Windows: 
  Settings → Windows Defender Firewall 
  → Allow an app through firewall
  → Find Python → Enable

macOS:
  System Preferences → Security & Privacy
  → Firewall Options → Allow incoming connections

Linux:
  sudo ufw allow 5000
```

#### Solution

```
QUICK FIX:
1. Force close app completely
2. Restart Flask backend server (Ctrl+C, then python app.py)
3. Restart WiFi on mobile device
4. Reopen app - wait 10 seconds for auto-discovery
5. If still failing: Go to Settings → Manual IP entry

MANUAL IP FIX:
1. Settings → Server IP → 192.168.X.X:5000
2. Replace X.X with your backend IP (check ipconfig or ifconfig)
3. Tap Connect
4. Wait 5 seconds
5. Check if Dashboard loads

VERIFY BACKEND IP:
Windows: ipconfig | findstr IPv4
macOS: ifconfig | grep "inet " 
Linux: ifconfig | grep inet
```

### Issue 2: Stale or Missing Sensor Data

#### Symptoms
```
"Last Updated: 2 hours ago"
"All sensors show dashes (--)"
"Dashboard completely empty"
```

#### Diagnosis

**Step 1: Check APEX Connection**
Backend logs should show:
```
✓ APEX polling cycle started
✓ Retrieved 8 sensor readings from APEX
✓ Data aggregated successfully
```

If showing errors like:
```
✗ APEX polling failed: HTTP 404
✗ Connection timeout to APEX endpoint
✗ Invalid ORACLE_APEX_URL
```

**Step 2: Verify APEX Endpoint**
```powershell
# Test APEX directly in browser:
curl "https://oracleapex.com/ords/g3_data/iot/greenhouse/"

# Should return JSON sensor data
# If 404 or timeout: APEX is unreachable
```

**Step 3: Check Internet Connection**
```
Backend machine must have internet access
Verify: ping google.com
Should respond with reply times
```

#### Solution

```
QUICK FIX:
1. Verify ORACLE_APEX_URL in .env file is correct
2. Verify Oracle APEX service is online
3. Restart Flask backend: Ctrl+C then python app.py
4. Refresh app dashboard (pull down)
5. Wait 15 seconds for new data

IF STILL FAILING:
6. Check .env file ORACLE_APEX_URL:
   Should be: https://oracleapex.com/ords/g3_data/iot/greenhouse/
   
7. Manually test APEX endpoint in browser
   
8. Check backend logs for specific error

9. If APEX returns 404:
   - Contact database administrator
   - Verify APEX is running
   - Confirm endpoint URL hasn't changed
   
10. Restart everything:
    - Backend server
    - App (force close and reopen)
    - Try manual refresh
```

### Issue 3: AI Recommendations Not Loading

#### Symptoms
```
"🤖 AI Insights: Loading..."
"No AI analysis available"
"Fallback advice shown instead"
```

#### Diagnosis

**Step 1: Check Gemini API Key**
Backend `.env` must have:
```
GEMINI_API_KEY=your-actual-key-here
```

If blank or missing: AI is disabled

**Step 2: Verify API Key is Valid**
Backend logs should show:
```
✓ Gemini API: Successfully initialized
✓ AI analysis available
```

If showing:
```
✗ Gemini API key invalid
✗ API authentication failed
```

**Step 3: Check Backend Internet**
```
Backend needs internet for Google Gemini
Verify: ping google.com
Should respond successfully
```

#### Solution

```
AI NOT CRITICAL - APP STILL WORKS:
The app includes built-in fallback recommendations
All advice is provided, just not AI-enhanced

TO ENABLE AI:
1. Get free API key:
   https://makersuite.google.com/app/apikey
   
2. Add to .env file:
   GEMINI_API_KEY=your-key-here
   
3. Restart Flask backend:
   Ctrl+C
   python app.py
   
4. Restart app (force close and reopen)

5. Check backend console shows:
   "✓ Gemini AI: Successfully initialized"
   
6. Try AI recommendations again
   Should now show AI-powered insights
```

### Issue 4: PDF Export Fails

#### Symptoms
```
"Report generation failed"
"PDF not created"
"Timeout during export"
"Error generating report"
```

#### Diagnosis

**Step 1: Check Backend Storage**
```
Need at least 100MB free disk space

Windows: C:\ → Right-click → Properties
macOS: Finder → About This Mac → Storage
Linux: df -h | grep root
```

**Step 2: Verify ReportLab Library**
```powershell
pip list | findstr reportlab

Should show: reportlab 3.6.x
```

#### Solution

```
QUICK FIX:
1. Free up disk space if needed (delete old files)
2. Restart Flask backend
3. Try exporting report again

IF STILL FAILING:
4. Reinstall ReportLab:
   pip uninstall reportlab -y
   pip install reportlab==3.6.12
   
5. Restart backend server

6. Try export again

IF ERROR PERSISTS:
7. Check temp directory permissions:
   Windows: C:\Temp or %TEMP%
   macOS: /var/tmp
   Linux: /tmp
   
8. Check backend logs for specific error

9. Contact system administrator with error message
```

### Issue 5: Slow Dashboard Response

#### Symptoms
```
"Dashboard takes 5+ seconds to load"
"Sensor values update slowly"
"App freezes temporarily"
```

#### Causes & Solutions

```
CAUSE 1: High Backend CPU Usage
FIX: 
- Open Task Manager (Windows)
- Find "python app.py" process
- If CPU > 80%: Restart backend
- If RAM > 500MB: May need upgrade

CAUSE 2: Poor WiFi Signal
FIX:
- Check WiFi signal strength (3+ bars)
- Move closer to router
- Check for interference (microwave, cordless phone)
- Switch to 5GHz if available

CAUSE 3: Large Historical Data
FIX:
- Dashboard loads 24 hours by default
- Switch to "Last Hour" view instead
- Reduces data points from 1000+ to ~60
- Performance should improve immediately

CAUSE 4: APEX Database Slow
FIX: (depends on database)
- Backend polls APEX every 10 seconds
- If APEX slow: Backend waits
- Contact database administrator

QUICK OPTIMIZATION:
1. Close other apps on device
2. Restart WiFi connection
3. Force close and reopen app
4. Monitor performance - should improve
```

### Issue 6: Android APK Installation Fails

#### Symptoms
```
"App not installed"
"Parse error"
"Installation blocked"
"Insufficient storage"
```

#### Diagnosis & Solutions

**Error: "Parse error"**
```
CAUSE: APK corrupted or wrong Android version
FIX:
1. Delete downloaded APK file
2. Get fresh copy from administrator
3. Check Android version: Settings → About Phone
4. Must be Android 7.0 or higher
5. Try installation again
```

**Error: "Installation blocked"**
```
CAUSE: Security setting blocking unknown sources
FIX:
1. Settings → Security → Unknown Sources
2. Enable "Allow installation from unknown sources"
3. Or: Settings → Apps → Special app access
4. Enable "Install unknown apps" for file manager
5. Try installation again
```

**Error: "Insufficient storage"**
```
CAUSE: Not enough free space
FIX:
1. Delete unnecessary files/apps
2. Free up at least 150MB space
3. Try installation again
```

**Error: "Installation cancelled"**
```
CAUSE: Process interrupted or connection dropped
FIX:
1. Try installation again
2. Or use command line (if adb installed):
   adb install app-release.apk
```

#### Verification After Install
- App appears in app drawer
- Tap to launch (may take 30 seconds first time)
- Grant permission requests
- Should show "Allow" / "Deny" prompts

### Issue 7: Notifications Not Appearing

#### Symptoms
```
"No alert notifications received"
"Missed critical alerts"
"Alerts appear hours late"
```

#### Diagnosis & Solution

```
CHECK 1: App Permissions
Settings → Apps → EcoView → Permissions
Verify: ✓ Notifications: Allowed

FIX: If disabled, enable

CHECK 2: Battery Optimization
Settings → Battery → Battery optimization
Find EcoView → Select "Don't optimize"
Reason: Optimization puts app to sleep

CHECK 3: WiFi Connection
Notifications require internet connection
Verify: WiFi is connected and working

CHECK 4: Do Not Disturb
Critical alerts (Flame, Extreme Temp) bypass DND
Other alerts may be silenced
Check: Settings → Sound & vibration

FULL RESET:
1. Settings → Apps → EcoView
2. Tap "Storage" → Clear Cache
3. Tap "Permissions" → Allow all
4. Force Stop app
5. Restart device
6. Reopen app and grant permissions
7. Notifications should work now
```

### Issue 8: Backend Process Keeps Crashing

#### Symptoms
```
Backend server stops unexpectedly
"Segmentation fault"
"Out of memory"
"Process terminated"
```

#### Diagnosis

**Step 1: Check Backend Logs**
```powershell
# Run backend with logging:
python app.py 2>&1 | tee app.log

# Look for error messages before crash
```

**Step 2: Monitor System Resources**
```
Windows: Task Manager → Processes
macOS: Activity Monitor
Linux: top or htop
Watch for: High CPU, High RAM usage
```

#### Solution

```
COMMON CAUSE 1: Memory Leak
FIX:
1. Stop backend (Ctrl+C)
2. Restart backend: python app.py
3. Monitor memory usage
4. If grows over time: Memory leak exists
5. Contact developer with logs

COMMON CAUSE 2: APEX Connection Timeout
FIX:
1. Verify APEX is online and responsive
2. Increase timeout in app.py (if needed)
3. Restart backend

COMMON CAUSE 3: Database File Locked
FIX:
1. Stop backend
2. Delete .db-wal and .db-shm files if present
3. Restart backend

TROUBLESHOOTING:
1. Check error logs for specific error
2. Verify Python version: python --version
3. Reinstall dependencies: pip install -r requirements.txt --force-reinstall
4. Try on different machine if possible
```

---

## Best Practices

### Daily Operations

#### Morning Routine (5 minutes)
1. **Check Dashboard** for overnight readings
2. **Review Alerts** - address any red/yellow alerts
3. **Monitor Trends** - tap sensors for quick analysis
4. **Document Issues** - note any problems for later

#### Afternoon Check (5 minutes)
1. **Verify Sensors** - confirm all 8 showing data
2. **Check Critical Values** - focus on temperature/humidity/flame
3. **Generate Quick Report** if needed for records

#### Evening Review (10 minutes)
1. **Export Daily Report** - save PDF for archive
2. **Review AI Recommendations** - plan next actions
3. **Note Any Changes** - prepare for tomorrow

### Sensor Maintenance Schedule

#### Weekly Tasks
- **Visual Inspection**: Check all sensor connections
- **Lens Cleaning**: Clean light sensor (LDR) lens
- **Probe Check**: Verify soil moisture probe contact
- **Temperature Verification**: Check against manual thermometer

#### Monthly Tasks
- **Deep Clean**: Clean all sensors with soft cloth
- **Calibration Check**: Verify readings are accurate
- **Connection Review**: Inspect all wiring for damage
- **Database Backup**: Export data for long-term storage

#### Quarterly Tasks
- **Sensor Replacement**: Consider replacing gas sensors (MQ135, MQ2, MQ7)
- **System Performance**: Check if app/backend running smoothly
- **Documentation Update**: Update any configuration changes
- **Full Validation**: Test all features end-to-end

### Data Management

#### Archive Strategy
```
Keep in System: Current month + last month
Archive: Older than 2 months
Long-term Storage: Export quarterly to external drive

Storage Needs:
- ~50MB per month of data
- Monitor available space
- Archive when 80% full
```

#### Backup Procedure
```
What to Backup:
- greenhouse.db (sensor data)
- .env file (configuration)
- Generated reports (PDFs)
- Backend logs (troubleshooting)

Frequency: Weekly minimum
Location: External drive or cloud storage
Retention: Keep 3-6 months
```

### Network Security (Local Network)

#### WiFi Security
- Use WPA2 or WPA3 encryption
- Change default WiFi password immediately
- Consider hiding SSID
- Update router firmware regularly

#### Device Security
- Lock mobile device with PIN/biometric
- Keep OS and apps updated
- Don't leave device unattended
- Review app permissions regularly

#### Backend Security Notes
```
⚠️ IMPORTANT: Development Setup is NOT Secure

Current Limitations:
- No SSL/TLS encryption
- No user authentication
- No rate limiting
- Debug mode enabled

For Production Use (Future):
1. Enable SSL certificates
2. Add user authentication
3. Disable debug mode
4. Implement rate limiting
5. Use environment-specific configs
6. Consider VPN for remote access
```

### Optimal Configuration

#### Refresh Interval Settings
```
Too Frequent (< 10 seconds):
- Wastes mobile battery
- Overloads backend
- No practical benefit

Recommended (30 seconds):
- Balances responsiveness
- Minimal battery drain
- Good for most use cases

Less Frequent (> 5 minutes):
- Better for background monitoring
- May miss critical alerts
- Only use if necessary
```

---

## FAQ

### General Questions

**Q: Can I use EcoView without internet?**
A: Yes! The app and backend communicate over local WiFi only. No cloud connection required. Internet only needed for Google Gemini AI (optional).

**Q: What happens if backend machine reboots?**
A: App will show "Connection failed" until backend restarts. Data is preserved - just refresh app when backend is back online.

**Q: Can multiple people use the app simultaneously?**
A: Yes, multiple devices can connect to the same backend. Each gets identical data. Alerts are independent per device.

**Q: Is my greenhouse data stored in the cloud?**
A: No, all data stored locally in Oracle APEX database on your network. For cloud backup, manually export PDF reports.

**Q: How long does the system keep historical data?**
A: Data stored indefinitely until manually archived. No automatic deletion. Monitor storage space.

### Technical Questions

**Q: What's the maximum number of sensors?**
A: Currently 8 sensors implemented. Architecture supports more with code modifications.

**Q: Can I change how often the backend polls APEX?**
A: Yes, edit polling interval in app.py (currently 10 seconds). Requires Python restart.

**Q: What if one sensor fails?**
A: That sensor stops reporting; others continue normally. Dashboard shows red indicator for failed sensor.

**Q: Can I add custom sensors?**
A: Yes, if sensors added to APEX database. Modify THRESHOLDS.md and app.py accordingly.

### Deployment Questions

**Q: Can I deploy to multiple greenhouse locations?**
A: Currently designed for single site. Would need separate backend per location.

**Q: What's the WiFi range?**
A: Standard WiFi (50-150 feet typical). Depends on router and obstacles. Use WiFi extender if needed.

**Q: Can I access EcoView over the internet?**
A: Not without modifications. Current setup local-only. Would require SSL, authentication, firewall config.

**Q: How do I password-protect the app?**
A: Not currently implemented. Relies on WiFi network security. Consider adding if deploying to public spaces.

### Troubleshooting Questions

**Q: My backend keeps crashing. Why?**
A: Check logs: `python app.py 2>&1 | tee app.log`
Common causes: Memory leak, APEX timeout, database file locked

**Q: App freezes when exporting reports.**
A: Report generation is CPU-intensive. Wait 30-60 seconds. Close other apps.

**Q: Auto-discovery isn't working.**
A: Alternate: Settings → Manual IP entry. Enter backend IP address directly.

**Q: Backend CPU usage is always high.**
A: Check if APEX polling is timing out. Increase timeout value or contact database admin.

---

## Appendix

### Sensor Specifications & Thresholds

#### Temperature (°C)
**Sensor**: DHT22 + BMP280 (dual sensor redundancy)
- **Optimal**: 20-27°C (ideal for most plants)
- **Acceptable**: 18-20°C or 27-30°C
- **Critical**: <18°C or >30°C
- **Accuracy**: ±2°C
- **Range**: -40°C to +85°C

#### Humidity (%)
**Sensor**: DHT22
- **Optimal**: 45-70% (prevents disease, supports growth)
- **Acceptable**: 71-80%
- **Critical**: <45% or >80%
- **Accuracy**: ±5%
- **Range**: 0-100%

#### Soil Moisture (%)
**Sensor**: Capacitive moisture probe
- **Optimal**: 40-60% (well-hydrated)
- **Acceptable**: 30-40% or 60-70%
- **Critical**: <30% or >70%
- **Range**: 0-100%

#### Light Intensity (Raw ADC 0-4095)
**Sensor**: LDR photoresistor
- **Dark Night**: 0-300 (no light)
- **Low Light**: 301-819 (dim conditions)
- **Dim Indoor**: 820-1638 (early dusk)
- **Moderate**: 1639-2457 (cloudy day)
- **Bright**: 2458+ (full daylight)
- **Note**: Raw ADC values, not lux measurements

#### Air Quality (ppm)
**Sensor**: MQ135
- **Good**: ≤200 ppm
- **Moderate**: 201-500 ppm
- **Poor**: >500 ppm
- **Range**: 0-500+ ppm

#### CO₂ Levels (calculated from MQ135)
**Calculation**: `CO2 = 400 + (mq135_drop × 1.2)`
- **Good**: 300-800 ppm
- **Moderate**: 800-1500 ppm
- **High**: >1500 ppm

**Combined Air Quality Status**:
- **Optimal**: MQ135 ≤200 ppm AND CO2 300-800 ppm
- **Good**: One sensor in good range
- **Moderate**: One or both moderate
- **High**: One or both poor
- **Critical**: BOTH MQ135 >500 ppm AND CO2 >1500 ppm

#### Smoke Detection (MQ2)
**Sensor**: MQ2 flammable gas sensor
- **Safe**: ≤300 ppm
- **Elevated**: 300-750 ppm
- **High/Danger**: >750 ppm
- **Range**: 0-750+ ppm

#### Carbon Monoxide Detection (MQ7)
**Sensor**: MQ7 CO sensor
- **Safe**: ≤300 ppm
- **Elevated**: 300-750 ppm
- **High/Danger**: >750 ppm
- **Range**: 0-750+ ppm

#### Flame Detection
**Sensor**: Infrared flame detection
- **Safe**: No flame detected (🟢 Green)
- **Critical**: Flame detected (🔴 Red)
- **Range**: Boolean (ON/OFF)

### API Endpoints Reference

```
GET  /api/health
     Returns: {"status":"healthy","timestamp":"ISO8601"}

GET  /api/sensor-data
     Returns: Latest readings for all 8 sensors

GET  /api/sensor-analysis/<sensor_type>
     Returns: Statistics and trends for specific sensor

GET  /api/sensor-analysis/<sensor_type>/ai
     Returns: AI-powered insights for sensor

GET  /api/ai-recommendations
     Returns: Consolidated AI recommendations

GET  /api/alerts
     Returns: Current critical and warning alerts

GET  /api/export-report
     Returns: PDF file download
```

### Keyboard Shortcuts (Desktop Version)

| Shortcut | Action |
|----------|--------|
| `R` | Refresh sensor data |
| `D` | Go to Dashboard |
| `A` | View AI Recommendations |
| `S` | Open Settings |
| `P` | Export PDF Report |
| `Q` | Quit application |
| `Ctrl+C` | Stop backend server |

### File Structure Reference

```
Windows:
Backend Config:    C:\Users\YourName\sturdy-giggle\python_backend\.env
Database:          C:\Users\YourName\sturdy-giggle\python_backend\greenhouse.db
Reports:           C:\Users\YourName\Downloads\greenhouse_report_*.pdf
Backend Logs:      C:\Users\YourName\sturdy-giggle\python_backend\app.log

Linux/macOS:
Backend Config:    ~/sturdy-giggle/python_backend/.env
Database:          ~/sturdy-giggle/python_backend/greenhouse.db
Reports:           ~/Downloads/greenhouse_report_*.pdf
Backend Logs:      ~/sturdy-giggle/python_backend/app.log
```

### Common Commands Reference

**Backend Server Management:**
```powershell
# Start backend
python app.py

# Stop backend
Ctrl+C

# Check if running
curl http://localhost:5000/api/health

# View logs
type app.log (Windows)
tail -f app.log (Linux/macOS)
```

**Virtual Environment:**
```powershell
# Activate (Windows)
.venv\Scripts\Activate.ps1

# Activate (Linux/macOS)
source .venv/bin/activate

# Deactivate (all platforms)
deactivate
```

**Flutter Frontend:**
```bash
# Get dependencies
flutter pub get

# Run on specific device
flutter run -d windows
flutter run -d macos
flutter run -d linux
flutter run -d chrome

# Build APK
flutter build apk --release

# Clean build
flutter clean
```

---

## Support & Contact

### Self-Help Resources

1. **Check This Manual** - Most common issues covered
2. **Review Backend Logs** - Look for error messages
3. **Verify Connections** - Ensure all components online
4. **Test Health Endpoint** - `curl http://localhost:5000/api/health`

### When to Contact Administrator

- Backend configuration issues
- APEX database problems
- Network setup difficulties
- Permission or access issues
- Hardware installation questions

### Information to Provide When Reporting Issues

1. **Error Message** (screenshot if possible)
2. **When It Occurs** (specific time/action)
3. **Device Information** (Android version, app version)
4. **Network Information** (WiFi name, backend IP)
5. **Relevant Logs** (backend logs or app logs)

### Reporting Template

```
Device: Samsung Galaxy A10
OS: Android 11
EcoView Version: 1.0.0
Backend: 192.168.1.50:5000

Issue: [Describe what's happening]

When: [Specific time or action that triggers it]

Already Tried:
- [What troubleshooting steps have been attempted]

Error Message: [Exact error text]

Logs: [Attach relevant log output]
```

---

## Document Information

**Document Version**: 2.0  
**Last Updated**: November 5, 2025  
**System Version**: EcoView 1.0  
**Deployment Type**: Local Network WiFi  
**Scope**: Development & Testing  
**Not For**: Production/App Store Distribution (as-is)

---

## Change Log

| Version | Date | Changes |
|---------|------|---------|
| 2.0 | Nov 5, 2025 | Complete rewrite with correct thresholds, comprehensive troubleshooting |
| 1.0 | Oct 2025 | Initial manual creation |

---

*For updates to this manual, please contact the system administrator or visit the GitHub repository.*

**Repository**: https://github.com/Ismail-deb/sturdy-giggle

*End of User Manual*
