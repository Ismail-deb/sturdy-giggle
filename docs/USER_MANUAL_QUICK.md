# EcoView - Quick User Manual (Realistic Setup)

## Table of Contents
1. [How We Set It Up](#how-we-set-it-up)
2. [Platform Options](#platform-options)
3. [Getting the App Running](#getting-the-app-running)
4. [Dashboard Overview](#dashboard-overview)
5. [Viewing Sensor Data](#viewing-sensor-data)
6. [Alerts & Notifications](#alerts--notifications)
7. [Generating Reports](#generating-reports)
8. [Connection Issues & Fixes](#connection-issues--fixes)
9. [Daily Usage](#daily-usage)
10. [FAQ](#faq-real-questions-we-had)
11. [Quick Reference Card](#quick-reference-card)

---

## How We Set It Up

### What We Did (Step by Step)

**1. Backend Installation (Windows 11)**
```powershell
cd python_backend
pip install flask flask-cors requests python-dotenv reportlab==4.4.4
```
- Created `.env` with ORACLE_APEX_URL
- Started server: `python app.py`
- Server broadcasts on local network

**2. Flutter App Setup**
```powershell
cd flutter_frontend
flutter pub get
flutter run -d chrome
```
- Ran on Chrome for testing (fastest)
- App auto-discovered backend via UDP broadcast
- Connected successfully to `192.168.1.100:5000`

**3. Verified Everything Works**
- ✅ Backend polling APEX every 3 seconds
- ✅ App receiving live sensor data
- ✅ Dashboard with 10 sensor cards (Temperature, Humidity, Soil, Light, Air Quality, Flammable Gas, CO, Pressure, CO₂, Altitude)
- ✅ PDF export working with AI recommendations

**4. Built Mobile App (Android)**
```powershell
cd flutter_frontend
flutter build apk --release
```
- Generated: `build/app/outputs/flutter-app-release.apk`
- Copied to mobile device
- Users can install directly or via file transfer

---

## Platform Options

### Choose Your Platform

The EcoView app runs on **3 different platforms**. Pick the one that fits you:

| Platform | Device | How to Install | Best For |
|----------|--------|---|---|
| **📱 Android Mobile** | Phone/Tablet | APK file + tap to install | Most people - portable & convenient |
| **💻 Windows Desktop** | Windows PC/Laptop | `flutter run -d windows` | Office/Workstation monitoring |
| **🌐 Web Browser** | Chrome/Firefox | `flutter run -d chrome` | Quick testing, no installation |

### Real Setup We Used

**Mobile**: Built APK using `flutter build apk --release` and sent to team members
**Desktop**: Ran on Windows for backend development/testing
**Web**: Used Chrome during development for fastest testing

### Platform Comparison

| Feature | Android | Windows | Web |
|---------|---------|---------|-----|
| Installation | 1 tap (APK) | Requires Flutter SDK | None (browser) |
| Performance | Fast | Very Fast | Good |
| Offline | ❌ No | ✅ Yes | ❌ No |
| Auto-start on boot | ✅ Yes | ❌ No | ❌ No |
| File export | ✅ (PDF) | ✅ (PDF) | ✅ (PDF) |
| Network required | ✅ WiFi | ✅ WiFi | ✅ WiFi |
| Recommended | ✅ **BEST** | Good for office | Good for testing |

---

## Getting the App Running

### Option 1: Android Mobile (APK) - Easiest & Most Popular

**📱 On Your Android Phone:**

1. **Receive the APK file**
   - File: `flutter-app-release.apk`
   - Size: ~50-60 MB
   - From: USB transfer, email, or cloud drive

2. **Enable installation from unknown sources**
   - Settings → Security → Unknown Sources → Enable
   - (Or: Settings → Apps & notifications → Special app access → Install unknown apps → Your file manager → Allow)

3. **Install the APK**
   - Open file manager, find `flutter-app-release.apk`
   - Tap to install
   - Wait 5-10 seconds
   - App appears in your app drawer

4. **First time opening the app**
   - Tap app icon (🌱 EcoView)
   - App auto-discovers backend on your home WiFi
   - Dashboard loads automatically
   - **No setup needed** - just works! ✅

5. **If auto-discovery fails** (different WiFi or 5GHz)
   - Tap ⚙️ Settings icon
   - Select "Manual IP Address"
   - Enter backend IP: `192.168.1.100` (example)
   - Keep port: `5000`
   - Tap [Test Connection]
   - Wait for ✅ confirmation

**Real APK we built:**
- Command: `flutter build apk --release`
- Build time: ~3 minutes
- Output file: `build/app/outputs/flutter-app-release.apk`
- Compatibility: Android 5.0+ (API 21+)
- Install method: Direct APK or via package manager

### Option 2: Windows/Chrome (Web)

**💻 On Your Computer:**

1. **Start the backend first**
   ```powershell
   cd python_backend
   python app.py
   ```
   Wait for: `✅ APEX poll successful!`

2. **Run Flutter app for web/desktop**
   ```powershell
   cd flutter_frontend
   flutter pub get
   flutter run -d chrome      # For web browser
   flutter run -d windows     # For Windows desktop
   ```

3. **App automatically discovers backend**
   - Connects to `192.168.1.100:5000`
   - Dashboard appears
   - Live sensor data shows

4. **If connection fails**
   - Check backend is running (look for `✅ APEX poll successful!`)
   - Try manual IP in Settings
   - Verify both on same WiFi network

### Option 3: Building Your Own APK

**If you need to rebuild the app:**

```powershell
cd flutter_frontend

# Option A: Release build (for distribution)
flutter build apk --release
# Output: build/app/outputs/flutter-app-release.apk

# Option B: Debug build (for testing)
flutter build apk --debug
# Output: build/app/outputs/flutter-app-debug.apk

# Option C: Install directly to connected phone
flutter install -d <device-id>
```

**After building:**
- APK file ready in `build/app/outputs/`
- Share via email, USB, cloud drive, messaging
- Users install directly on Android phone

### Real World Scenario: How We Did It

**On Your Computer (Backend):**
1. Open terminal/PowerShell
2. Navigate to `python_backend` folder
3. Run: `python app.py`
4. You'll see console output like:
   ```
   ✅ APEX poll successful! Got 20 readings
   📤 Broadcasting to local network: 192.168.1.100:5000
   🤖 AI service ready (fallback mode)
   ```

**On Mobile Device (with APK installed):**
1. Tap app icon (🌱 EcoView)
2. App automatically finds your backend server
3. Dashboard appears with live greenhouse data
4. **No manual setup needed** - just works! ✅

**On Windows/Web:**
1. Run Flutter app: `flutter run -d chrome`
2. Browser opens automatically
3. App connects to backend
4. Dashboard shows live data

### If Auto-Discovery Doesn't Work

This happened to us when:
- Network firewall blocked UDP broadcast
- Device on different WiFi band (5GHz vs 2.4GHz)
- Backend port changed

**Solution we used:**
1. Open App → Settings (⚙️)
2. Select: "Manual IP Address"
3. Enter backend IP: `192.168.1.100`
4. Keep port: `5000`
5. Tap "Test Connection"
6. Wait for ✅ confirmation
7. Close settings - dashboard updates

---

## Dashboard Overview

### What You See When It Works

**Live readings from APEX (every 3 seconds):**

Dashboard displays 10 sensor cards in a responsive grid:

```
🏡 EcoView Dashboard          [↻ Refresh]
═════════════════════════════════════════

Status: All Systems Normal ✅ (3 seconds ago)

┌─────────────────────────────────────┐
│  🌡️ TEMPERATURE    💧 HUMIDITY     │
│  28.9°C            43.5%           │
│  (Optimal 21-27)   (Optimal 60-75) │
│                                   │
│  🌱 SOIL MOISTURE  ☀️ LIGHT       │
│  36%               1133 lux        │
│  (Optimal 50-70)   (Optimal 2K-5K)│
│                                   │
│  🌫️ AIR QUALITY    🔥 FLAMMABLE   │
│  0 ppm             0 ppm          │
│  MQ135 Safe        MQ2 Safe       │
│                                   │
│  🌬️ CARBON MONOXIDE 📍 PRESSURE   │
│  0 ppm             1005 hPa       │
│  MQ7 Safe          Safe Range     │
│                                   │
│  ☁️ CO₂            ⬆️ ALTITUDE    │
│  400 ppm           5.8 m          │
│  Normal            Reference      │
└─────────────────────────────────────┘

⚠️ Alerts: None active

Navigation: [🔔] [📊] [📄] [⚙️]
```

### Real Data from APEX System (Live)

**Current readings (live from APEX sensor network) - 10 Dashboard Cards:**
- 🌡️ **Temperature:** 28.9°C (BMP280: 29.21°C + DHT22: 28.5°C average) - Optimal range 21-27°C
- 💧 **Humidity:** 43.5% - Optimal range 60-75%
- 🌱 **Soil Moisture:** 36% - Optimal range 50-70%
- ☀️ **Light Intensity:** 1133 lux - Optimal range 2000-5000 lux
- 🌫️ **Air Quality (MQ135):** 0 ppm - Good (<200 ppm = good)
- 🔥 **Flammable Gas (MQ2):** 0 ppm - Safe (<300 ppm = safe)
- 🌬️ **Carbon Monoxide (MQ7):** 0 ppm - Safe (<300 ppm = safe)
- � **Pressure:** 1005 hPa - Normal atmospheric pressure
- ☁️ **CO₂ Level:** 400 ppm - Normal outdoor/greenhouse level
- ⬆️ **Altitude:** 5.8 m - Reference elevation

**System Status:** All sensors operational and reporting ✅

### Understanding the 10 Dashboard Cards

Each card on the dashboard provides real-time monitoring of a specific greenhouse parameter. Here's what each one shows:

#### 1. 🌡️ Temperature Card
- **What it shows:** Average temperature from BMP280 and DHT22 sensors
- **Example reading:** 28.9°C
- **Optimal range:** 20-27°C (ideal for most greenhouse plants)
- **Status colors:** ✅ Green (20-27°C), ⚠️ Yellow (18-20 or 27-30°C), 🔴 Red (<18 or >30°C)
- **Action needed:** Adjust ventilation, heating, or cooling if yellow/red

#### 2. 💧 Humidity Card
- **What it shows:** Relative humidity from DHT22 sensor  
- **Example reading:** 43.5%
- **Optimal range:** 45-70% (prevents disease while avoiding drought stress)
- **Status colors:** ✅ Green (45-70%), ⚠️ Yellow (40-45 or 70-80%), 🔴 Red (<40 or >80%)
- **Action needed:** Adjust ventilation, use humidifier/dehumidifier

#### 3. 🌱 Soil Moisture Card
- **What it shows:** Soil moisture percentage from capacitive sensor
- **Example reading:** 36%
- **Optimal range:** 40-60% (balanced water and oxygen for roots)
- **Status colors:** ✅ Green (40-60%), ⚠️ Yellow (30-40 or 60-70%), 🔴 Red (<30 or >70%)
- **Action needed:** Adjust irrigation or improve drainage

#### 4. ☀️ Light Intensity Card
- **What it shows:** Light sensor reading (lower number = brighter)
- **Example reading:** 497
- **Thresholds:** 0-250 Bright, 251-650 Moderate, 651-950 Dim, 951-1250 Dark Indoor, >1250 Dark Night
- **Status colors:** ✅ Green (0-650), ⚠️ Yellow (651-1250), 🔴 Red (>1250)
- **Action needed:** Add grow lights or remove shading if yellow/red

#### 5. 🌫️ Air Quality (CO₂) Card
- **What it shows:** Calculated CO₂ level from MQ135 sensor
- **Example reading:** 437 ppm
- **Optimal ranges:** 300-800 ppm Good, 800-1500 ppm Acceptable, >1500 ppm High
- **Status colors:** ✅ Green (300-800), ⚠️ Yellow (800-1500), 🔴 Red (<300 or >1500)
- **Action needed:** Adjust ventilation or CO₂ supplementation

#### 6. 🔥 Flammable Gas (MQ2) Card
- **What it shows:** Flammable gas/smoke from MQ2 sensor
- **Example reading:** 334 ppm
- **Safety thresholds:** ≤300 Safe, 301-750 Elevated, >750 High
- **Status colors:** ✅ Green (≤300), ⚠️ Yellow (301-750), 🔴 Red (>750)
- **Action needed:** Inspect heating equipment, check for gas leaks

#### 7. 🌬️ Carbon Monoxide (MQ7) Card
- **What it shows:** CO detection from MQ7 sensor
- **Example reading:** 54 ppm
- **Safety thresholds:** ≤300 Safe, 301-750 Elevated, >750 Dangerous
- **Status colors:** ✅ Green (≤300), ⚠️ Yellow (301-750), 🔴 Red (>750)
- **Action needed:** Check combustion equipment, ventilate immediately if red

#### 8. 📍 Pressure Card
- **What it shows:** Barometric pressure from BMP280 sensor
- **Example reading:** 1010.68 hPa
- **Normal range:** 990-1030 hPa
- **Status colors:** ✅ Green (990-1030), ⚠️ Yellow (980-990 or 1030-1040), 🔴 Red (<980 or >1040)
- **Action needed:** Monitor weather changes, adjust environmental controls

#### 9. ☁️ CO₂ Level Card
- **What it shows:** Alternative CO₂ view for quick reference
- **Same as Air Quality card - provides duplicate access to CO₂ monitoring**
- **Purpose:** Quick access without navigating to air quality details

#### 10. ⬆️ Altitude Card
- **What it shows:** Elevation from BMP280 sensor
- **Example reading:** 0.21 m
- **Purpose:** Reference measurement (greenhouse location elevation)
- **Note:** Stable value - doesn't require action unless erratic

**Quick Reference:**
- Cards 1-7: Daily plant health monitoring (check these daily)
- Cards 8-10: Environmental references (stable values)
- 🔴 Red = Immediate action needed
- ⚠️ Yellow = Plan adjustment soon  
- ✅ Green = All good!

### Real Data Update Cycle

- **APEX polling interval:** Every 3 seconds
- **Dashboard refresh:** Automatic, shows latest readings
- **Data source:** Oracle APEX endpoints
  - Primary: Greenhouse sensors (temperature, humidity, light, gas sensors, flame detection)
  - Secondary: Soil moisture supplement (if configured)
- **Status indicator:** Shows data freshness ("4 seconds ago")
```

### Real Data from Our APEX System

**Current readings (live from APEX sensor network):**
- �️ **Temperature:** 23.2°C (BMP280 + DHT22 average) - Optimal range 21-27°C
- 💧 **Humidity:** 65% (DHT22 sensor) - Optimal range 60-75%
- 🌱 **Soil Moisture:** 58% - Optimal range 50-70% (well balanced)
- ☀️ **Light Intensity:** 4500 lux - Optimal range 2000-5000 lux
- 🌫️ **Air Quality (MQ135):** 180 ppm - Good (<200 ppm = good)
- 🔥 **Flammable Gas (MQ2):** 120 ppm - Safe (<300 ppm = safe)
- 🌬️ **Carbon Monoxide (MQ7):** 85 ppm - Safe (<300 ppm = safe)
- 🔥 **Flame Detection:** No flame detected ✅

**All systems green ✅ = Everything working perfectly**

### Real Data Update Cycle

- **APEX polling interval:** Every 3 seconds
- **Dashboard refresh:** Automatic, shows latest readings
- **Data source:** Oracle APEX endpoints
  - Primary: Greenhouse sensors (temperature, humidity, light, gas sensors, flame detection)
  - Secondary: Soil moisture supplement (if configured)
- **Status indicator:** Shows how fresh the data is ("3 seconds ago")
│  (Optimal)         (Good)       │
└─────────────────────────────────┘

⚠️ Alerts: None active


Navigation: [📊] [📈] [🤖] [ℹ️] [📄] [⚙️]
```

### Real Data Example

Live data from APEX system at current time:
- **Temperature:** 28.9°C (BMP280 + DHT22 average) - warm, needs monitoring
- **Humidity:** 43.5% - low, below optimal
- **Soil Moisture:** 36% - low, watering recommended soon
- **Light:** 1133 lux - moderate, adequate for some plants
- **Air Quality (MQ135):** 0 ppm - good, clean air
- **Flammable Gas (MQ2):** 0 ppm - safe, no hazard
- **Carbon Monoxide (MQ7):** 0 ppm - safe, no hazard

System operational ✅ = All sensors responding correctly

### 📸 Dashboard Screenshots & How to Use Them

#### Screenshot 1: Main Dashboard Home Screen
**[INSERT IMAGE HERE: `docs/screenshots/01_dashboard_main.png`]**

**What you see:**
- Header: "🌱 EcoView - Greenhouse Monitor"
- Status bar: "✅ ALL SYSTEMS NORMAL"
- 10 cards in grid (2 columns × 5 rows):
  - Row 1: 🌡️ Temperature, 💧 Humidity
  - Row 2: 🌱 Soil Moisture, ☀️ Light
  - Row 3: 🌫️ Air Quality (CO₂), 🔥 Flammable Gas
  - Row 4: �️ Carbon Monoxide, 📍 Pressure
  - Row 5: ☁️ CO₂ Level, ⬆️ Altitude
- Each card shows icon, label, value, ✅ status color
- Timestamp: "✅ All readings fresh (3s ago)"

**How to interact with this screen:**
1. **Quick check:** Glance at all 10 sensors at once
2. **See trends:** Tap any card to view 24-hour graph
3. **Force refresh:** Tap ↻ button (if needed)
4. **Check alerts:** Tap 🔔 icon if you see yellow/red cards
5. **Export data:** Tap 📄 icon to generate PDF report
6. **Change settings:** Tap ⚙️ icon (usually just once at setup)

**Status colors:**
- ✅ **Green card:** Reading is in optimal range
- ⚠️ **Yellow card:** Reading is acceptable but monitor
- 🔴 **Red card:** CRITICAL - needs immediate attention

#### Screenshot 2: Sensor Detail View (Tap Temperature Card)
**[INSERT IMAGE HERE: `docs/screenshots/02_sensor_detail_temperature.png`]**

**What you see after tapping a sensor card:**
- Large display: "28.9°C" in big font (from APEX BMP280+DHT22 average)
- Subtitle: "Warm - Monitor" (or "Optimal" or "Critical")
- Range indicator: "Optimal 21-27°C | Alert 18-29°C | Critical <18 or >30"
- Graph: 24-hour line chart showing temperature trend from APEX data
- Stats: "Min: 20.8°C | Max: 31.2°C | Avg: 25.5°C"
- AI Note: "Temperature elevated above optimal range - consider ventilation"
- Data source: "From APEX polling (updated every 3 seconds)"
- [Back to Dashboard] button

**How to use this view:**
1. **Understand current status:** Big number + color shows if it's good
2. **See trends:** Blue line shows 24-hour pattern
   - Flat line = stable (good)
   - Rising line = increasing (might need ventilation)
   - Dip line = dropped (might need heating)
3. **Check ranges:** Compare to safe/alert zones at bottom
4. **Read AI tip:** Explains what the trend means for your plants
5. **Go back:** Tap [Back] or sensor card to return to dashboard

#### Screenshot 3: Active Alert Example
**[INSERT IMAGE HERE: `docs/screenshots/03_dashboard_with_yellow_alert.png`]**

**What you see when there's a ⚠️ yellow alert:**
- One card is highlighted in **YELLOW** (e.g., 💧 Humidity 75%)
- Other cards still green
- Bell icon 🔔 has a **red dot** notification indicator
- Small alert text below dashboard: "1 Alert Active"

**How to respond to alerts:**
1. **See yellow card:** Shows which sensor needs attention
2. **Tap 🔔 icon:** See full alert message and recommendation
3. **Take action:** Follow the suggested fix
   - "Humidity high → Open window or turn on fan"
   - "Light low → Turn on grow lights"
   - "Temperature high → Increase ventilation"
4. **Monitor:** Check again in 1-2 minutes to see if improving
5. **Expected update:** Next reading in 3 seconds shows progress

#### Screenshot 4: Alerts Panel (Tap 🔔 Bell Icon)
**[INSERT IMAGE HERE: `docs/screenshots/04_alerts_panel.png`]**

**What you see:**
- Full-screen alert details
- Each alert shows: Icon, sensor name, current value, recommendation
- Example alerts:
  ```
  ⚠️ HUMIDITY ALERT: 75%
  Recommendation: "Humidity is rising. Increase air circulation."
  
  ⚠️ TEMPERATURE WARNING: 27°C
  Recommendation: "Temperature is elevated. Open vents or reduce sun exposure."
  ```
- [Dismiss] button for each alert

**How to use:**
1. **Read recommendation:** Each alert explains what's happening
2. **Take action:** Use the suggestion to fix the issue
3. **Dismiss:** Remove alert once fixed
4. **Back to dashboard:** Watch graph update as conditions improve

#### Screenshot 5: Bottom Navigation Bar
**[INSERT IMAGE HERE: `docs/screenshots/05_bottom_navigation.png`]**

**What you see:**
```
Bottom bar with 4 icons:
🔔 Alerts    📊 Trends    📄 Reports    ⚙️ Settings
```

**How to use each section:**
- **🔔 Alerts:** Shows all active warnings (red + yellow alerts)
- **📊 Trends:** Detailed analytics with 7-day graphs (not main view)
- **📄 Reports:** Generate and download PDF exports
- **⚙️ Settings:** Configure backend IP address (one-time setup)

**Most common flow:**
- Open app → Dashboard (default)
- See alert → Tap 🔔 to read recommendation
- Ready to export → Tap 📄 to generate PDF
- Need to change IP → Tap ⚙️ to enter new address

---

---

## Viewing Sensor Data

### 📸 Detailed Sensor View Screenshots

#### Screenshot 1: Temperature Detail Screen
**[INSERT IMAGE HERE: `docs/screenshots/06_sensor_detail_temperature.png`]**

**Screen layout from top to bottom:**
1. Header: "← Back" button, "🌡️ TEMPERATURE" title
2. Big number: "22.5°C" in large font, ✅ green
3. Status line: "Status: Optimal ✅"
4. Range boxes:
   - Green box: "Safe 20-25°C"
   - Yellow box: "Alert 18-27°C"
   - Red box: "Critical <18°C or >28°C"
5. 24-hour trend data:
   - "📈 Highest: 24.3°C (today, 2:30 PM)"
   - "📉 Lowest: 21.2°C (today, 5:00 AM)"
   - "📊 Average: 22.8°C"
6. Graph: Blue line showing stable trend throughout day
7. AI Note: "Temperature stable - excellent conditions"
8. Buttons: [Close] [Share Data] [Export]

**How to use this screen:**
- **Big number (22.5°C):** Current temperature right now
- **Color indicator:** Green = safe, Yellow = warning, Red = critical
- **Range zones:** Shows what's acceptable vs dangerous
- **Graph line:** Flat line = stable (good), rising = getting hot, dipping = getting cold
- **AI note:** Simple explanation of what the data means
- **Share:** Send data to someone else
- **Export:** Save this sensor's data to PDF

#### Screenshot 2: Humidity Detail Screen (with yellow alert)
**[INSERT IMAGE HERE: `docs/screenshots/07_sensor_detail_humidity_alert.png`]**

**What you see (when humidity is 75%, yellow):**
- Big number: "75%" in **YELLOW** color
- Status line: "Status: Warning ⚠️ - Monitor"
- Range boxes showing yellow is in alert zone
- Trend showing upward line (humidity increasing)
- AI Note: "Humidity rising - recommend increasing ventilation"
- Alert recommendation: "💡 Suggestion: Open window or turn on fan"
- Buttons: [Close] [Take Action] [Dismiss Alert]

**How to use:**
1. **See yellow number:** Confirms humidity needs attention
2. **Check graph:** See if it's rising (↗) or stable
3. **Read AI note:** Get specific recommendation
4. **Take action:** Use suggestion (open window, turn on fan)
5. **Tap [Take Action]:** Logs that you responded to alert
6. **Monitor:** Close and check dashboard - next reading (3 sec) should show improvement

#### Screenshot 3: Soil Moisture Detail Screen
**[INSERT IMAGE HERE: `docs/screenshots/08_sensor_detail_soil.png`]**

**What you see:**
- Big number: "36%" in ⚠️ yellow (from APEX secondary soil endpoint)
- Visual indicator: Soil moisture bar showing "below optimal"
- Status: "Low - Watering recommended"
- Range: "Optimal 50-70% | Alert 30-80% | Too Dry <30% | Too Wet >80%"
- 24-hour trend: Graph showing dips (when watered) and gradual decline as plants absorb
- AI Note: "Soil moisture low - recommend watering within 1 hour"
- [Water Now] or [Set Reminder] button

**How to use:**
- **Big number (36%):** Shows soil wetness percentage from APEX
- **Graph dips:** Each dip shows watering event
- **Gradual slope:** Plants absorbing water naturally
- **AI prediction:** When next watering is needed
- **Tap [Water Now]:** Logs watering action and sets timestamp

#### Screenshot 4: Light Level Detail Screen
**[INSERT IMAGE HERE: `docs/screenshots/09_sensor_detail_light.png`]**

**What you see:**
- Big number: "1133 lux" in ⚠️ yellow (from APEX light sensor)
- Visual: Light bar showing "moderate light level"
- Status: "Low - Consider supplemental lighting"
- Range: "Optimal 2000-5000 | Alert 1000-2000 | Low <1000 | Excessive >6000"
- Time-based graph: Shows light variation throughout day
- Peak time: "Peak light: 12:30 PM (1800 lux)"
- AI Note: "Light levels ideal. Plants receiving optimal photosynthesis window"

**How to use:**
- **Big number:** Current light intensity in lux
- **Graph shape:** Should show peak midday, low at night
- **Peak info:** Shows best time of day for light
- **AI note:** Tells if grow lights needed or if natural light sufficient

#### Screenshot 5: CO₂ Level Detail Screen
**[INSERT IMAGE HERE: `docs/screenshots/10_sensor_detail_co2.png`]**

**What you see:**
- Big number: "0 ppm" in ✅ green (MQ135 sensor from APEX)
- Status: "Good - Clean air"
- Range: "Good <200 ppm | Moderate 200-500 ppm | Poor >500 ppm"
- Trend: Stable, flat line (consistent air quality)
- Sensor info: "MQ135 - Air quality sensor (APEX integrated)"
- AI Note: "Air quality excellent. Greenhouse air is clean and healthy"

**How to use:**
- **Big number (0 ppm):** Reading from MQ135 sensor via APEX
- **<200 = Green:** Good air quality, continue monitoring
- **200-500 = Yellow:** Moderate, may want ventilation
- **>500 = Red:** Poor air quality, needs ventilation immediately

#### Screenshot 6: Additional Gas Sensors (MQ2 Flammable Gas, MQ7 Carbon Monoxide)
**[INSERT IMAGE HERE: `docs/screenshots/11_sensor_detail_gas_safety.png`]**

**What you see:**
- **Flammable Gas (MQ2) - Current: 0 ppm**
  - Status: "Safe ✅"
  - Range: "Safe <300 ppm | Elevated 300-750 ppm | High >750 ppm"
  - Graph: Flat, stable line (good - no gas leaks)
  
- **Carbon Monoxide (MQ7) - Current: 0 ppm**
  - Status: "Safe ✅"
  - Range: "Safe <300 ppm | Elevated 300-750 ppm | High >750 ppm"
  - Graph: Flat, stable line (no CO buildup)

**How to use:**
- **Flammable Gas (MQ2):** Monitors for gas leaks or hazards
  - Green <300 = Safe, no concerns
  - Yellow 300-750 = Elevated, check ventilation
  - Red >750 = Critical, turn off all ignition sources
  
- **Carbon Monoxide (MQ7):** Monitors for exhaust/combustion hazards
  - Green <300 = Safe, healthy
  - Yellow 300-750 = Elevated, increase ventilation
  - Red >750 = Critical, evacuate and ventilate
- **Rising graph:** Bad - means particles accumulating (need ventilation)

### How We Actually Used the Detail Screens

**Real scenario 1: Morning check**
1. Opened app (dashboard)
2. Tapped 🌡️ Temperature card
3. Saw: 22.5°C stable, graph flat overnight
4. Thought: "Good, no temperature swings"
5. Went back to dashboard - moved on

**Real scenario 2: Alert on humidity**
1. Saw yellow card on dashboard 💧 Humidity 75%
2. Tapped humidity card for details
3. Saw: Graph rising upward (↗) since morning
4. Read AI note: "Humidity climbing - increase ventilation"
5. Opened windows → Came back in 5 minutes to check progress
6. Humidity dropped to 70% (green) ✅

**Real scenario 3: Checking if plants need water**
1. Tapped 🌱 Soil Moisture card (52%)
2. Saw graph: had a dip 3 hours ago (when we watered)
3. Saw trend: slowly declining (plants using water)
4. AI said: "Watering not needed for 8 hours"
5. Made mental note to check again after lunch

**Real scenario 4: Light levels during cloudy day**
1. Tapped ☀️ Light card
2. Saw: 2800 lux (lower than normal 4200)
3. Graph showed: dip in morning when clouds came
### How to Actually Use the Detail Screens (Real APEX Examples)

**Scenario 1: Morning system check with APEX data**
1. Open app (APEX has polled 3 seconds ago)
2. Tap 🌡️ Temperature card (showing 28.9°C)
3. See: Temperature elevated above optimal 21-27°C range
4. Check graph: Trending upward since morning
5. AI note: "Temperature elevated - consider ventilation"
6. Return to dashboard and open windows

**Scenario 2: Alert on low soil moisture from APEX**
1. See yellow card on dashboard 🌱 Soil 36%
2. Tap soil moisture card for details (APEX data)
3. See: Graph declining steadily (plants absorbing water)
4. Read AI note: "Soil moisture low - watering recommended"
5. Water the plants
6. Check again in 5 minutes to confirm increase

**Scenario 3: Checking air quality sensors from APEX**
1. Tap �️ Air Quality card (showing 0 ppm)
2. See: MQ135 readings excellent, clean air
3. Also check: MQ2 (0 ppm) and MQ7 (0 ppm) both safe
4. All gas sensors green - greenhouse is safe
5. Continue normal operations

**Scenario 4: Light levels during partly cloudy conditions**
1. Tap ☀️ Light card (showing 1133 lux)
2. See: Below optimal 2000-5000 lux range
3. Graph shows: Peaked at ~1800 lux at solar noon
4. AI note: "Light below optimal, consider supplemental lighting"
5. May need grow lights for sensitive plants

**Scenario 5: Monitoring humidity after ventilation**
1. Notice humidity 43.5% is low
2. Open windows for ventilation
3. Check humidity detail screen every 2 minutes
4. Wait for humidity to rise back to 60-75% range
5. Monitor APEX readings as they update every 3 seconds

**Key takeaways from real usage:**
- **Tap cards when concerned** - APEX data explains what's happening
- **Trust the AI analysis** - based on actual sensor data
- **Watch the graph** - shows 24-hour trend from APEX
- **Green = optimal, Yellow = monitor, Red = take action**
- **Data updates every 3 seconds** from APEX - always current

---

### All Sensor Ranges from APEX System

| Sensor | Optimal | Monitor | Critical |
|--------|---------|---------|----------|
| 🌡️ Temperature | 21-27°C | 18-30°C | <18 or >30°C |
| 💧 Humidity | 60-75% | 45-80% | <45 or >85% |
| 🌱 Soil Moisture | 50-70% | 30-80% | <25 or >85% |
| ☀️ Light | 2000-5000 lux | 1000-6000 | <500 lux |
| 🌫️ Air Quality (MQ135) | <200 ppm | 200-500 ppm | >500 ppm |
| 🔥 Flammable Gas (MQ2) | <300 ppm | 300-750 ppm | >750 ppm |
| 🌬️ Carbon Monoxide (MQ7) | <300 ppm | 300-750 ppm | >750 ppm |

---

## Alerts & Notifications

### 📸 Alert Screenshots & How to Respond

#### Screenshot 1: Yellow Alert on Dashboard
**[INSERT IMAGE HERE: `docs/screenshots/12_dashboard_yellow_alert.png`]**

**What you see:**
- One sensor card is **YELLOW** background (e.g., 💧 Humidity 75%)
- Other cards still green
- Bell icon 🔔 has a red dot indicator
- Dashboard message: "⚠️ 1 Alert Active"

**How to respond:**
1. **See yellow card** - identifies which sensor is concerned
2. **Tap 🔔 bell icon** - opens alerts panel with recommendation
3. **Read recommendation** - tells you what to do
4. **Take action** - follow the suggestion (e.g., open window)
5. **Wait 3 seconds** - next data update shows if improving
6. **Monitor** - if still yellow after 5 minutes, take stronger action

#### Screenshot 2: Alerts Panel (Full View)
**[INSERT IMAGE HERE: `docs/screenshots/13_alerts_panel_detail.png`]**

**Layout from top to bottom:**
1. Header: "🔔 ALERTS" 
2. Active alert card showing:
   ```
   ⚠️ HUMIDITY ALERT
   Current: 75%
   Target: 50-70%
   Status: Monitor Required
   
   Recommendation:
   "Humidity is elevated. Increase ventilation
   by opening windows or running fans."
   
   [Dismiss] [See Details] [Take Action]
   ```
3. If multiple alerts: Shows 2-3 stacked below
4. All Resolved Alerts section (collapsed)

**How to use alerts panel:**
- **[See Details]:** Shows detailed sensor screen
- **[Take Action]:** Logs that you're addressing it
- **[Dismiss]:** Removes alert (only when fixed)
- **Resolution time:** Most alerts auto-clear when value returns to safe range

#### Screenshot 3: Red Alert (Critical)
**[INSERT IMAGE HERE: `docs/screenshots/14_critical_alert.png`]**

**What you see (if temperature drops to 15°C):**
- Dashboard card is **RED**: "🌡️ 15°C 🔴"
- Bell icon **FLASHING RED** with urgent indicator
- Large alert banner: "🔴 CRITICAL ALERT - IMMEDIATE ACTION REQUIRED"
- Message: "Temperature critical (15°C). Plants at risk of damage."
- Recommendation: "Turn on heating immediately!"
- Button: [⚡ ACTIVATE HEATING] [See Details]

**How to respond:**
1. **DO NOT ignore** - red means plants are in danger
2. **Take immediate action** - follow the urgent recommendation
3. **Tap [See Details]** - understand what happened
4. **Monitor closely** - watch next 2-3 readings to confirm improving
5. **Once fixed** - alert auto-dismisses when temperature returns to safe range

#### Screenshot 4: Multiple Alerts Stacked
**[INSERT IMAGE HERE: `docs/screenshots/15_multiple_alerts.png`]**

**What you see:**
- Dashboard shows 2-3 sensors in yellow
- Bell icon shows: "3️⃣" badge (3 alerts)
- Alert panel shows all stacked:
  ```
  ⚠️ HUMIDITY: 76% - Increase ventilation
  ⚠️ TEMPERATURE: 27°C - Open vents/reduce light
  ⚠️ SOIL: 35% - Needs watering soon
  ```

**How to prioritize:**
1. **Address most urgent first** - red before yellow
2. **Look for root cause** - high temp + high humidity might both fix by opening window
3. **Take action** - tap [Take Action] for top alert
4. **Recheck** - often fixing one fixes multiple
5. **Monitor each** - tap individual alerts to see detailed recommendations

### Real Alert Examples from APEX System

| Alert | APEX Reading | Recommended Action | Expected Result |
|-------|---|---|---|
| High Temperature | 28.9°C (yellow) | Open windows/increase ventilation | Drop to 24-26°C in 5 min |
| Low Humidity | 43.5% (yellow) | Increase watering/misting | Rise to 60-70% in 10 min |
| Low Soil | 36% (yellow) | Water plants | Rise to 50-70% in 5 min |
| Low Light | 1133 lux (yellow) | Activate grow lights or wait for sun | Rise naturally to 2000+ at noon |
| Poor Air Quality | >500 ppm MQ135 (red) | Increase ventilation fans | Drop to <200 ppm in 10 min |
| Elevated Gas (MQ2) | >750 ppm (red) | Turn off ignition sources, ventilate | Drop to safe levels in 15 min |
| CO Detected (MQ7) | >750 ppm (red) | Evacuate greenhouse immediately | Check all ventilation systems |

### Alert Thresholds from APEX Backend Code

**Temperature alerts:**
- Yellow if <20 or >27°C | Red if <18 or >30°C

**Humidity alerts:**
- Yellow if <45 or >80% | Red if <30 or >85%

**Air Quality (MQ135):**
- Yellow if 200-500 ppm | Red if >500 ppm

**Flammable Gas (MQ2):**
- Yellow if 300-750 ppm | Red if >750 ppm

**Carbon Monoxide (MQ7):**
- Yellow if 300-750 ppm | Red if >750 ppm

### Alert Response Timing

- **Alert appears:** Within ~3 seconds of APEX reading exceeding threshold
- **You get notified:** Bell icon shows red dot indicator
- **AI recommendation:** Generated from APEX data, ready to tap
- **Action needed:** [See Details] shows full sensor view with current reading
- **Auto-clears:** When APEX value returns to safe range (within 3 seconds)

---

## Generating Reports

### 📸 Report Screenshots

#### Screenshot 1: Report Generation Screen
**[INSERT IMAGE HERE: `docs/screenshots/16_report_generation.png`]**

**What you see after tapping 📄 icon:**
```
┌─────────────────────────────────────┐
│ GENERATING GREENHOUSE REPORT        │
│                                     │
│ ⏳ Processing...                    │
│ • Collecting 24-hour data           │
│ • Calculating trends                │
│ • Generating PDF                    │
│ • Compressing file                  │
│                                     │
│ [Please wait 10-15 seconds]         │
│                                     │
└─────────────────────────────────────┘
```

**Timeline:**
- First 3 seconds: "Collecting data..."
- Next 5 seconds: "Generating report..."
- Last 3 seconds: "Ready to download!"

#### Screenshot 2: Report Ready Screen
**[INSERT IMAGE HERE: `docs/screenshots/17_report_ready.png`]**

**What you see when PDF is ready:**
```
✅ REPORT GENERATED SUCCESSFULLY

File: Greenhouse_Report_Nov2_2024.pdf
Size: 2.4 MB
Generated: Nov 2, 2024 3:45 PM

[📥 Download] [📤 Share] [📧 Email]
```

**Available actions:**
- **Download:** Saves to device's downloads folder
- **Share:** Sends via WhatsApp, Email, etc.
- **Email:** Sends directly to configured email

#### Screenshot 3: PDF Report Preview
**[INSERT IMAGE HERE: `docs/screenshots/18_report_preview.pdf`]**

**What's inside the PDF:**
1. **Header:**  
   - Report title: "EcoView Greenhouse Report"
   - Date generated: "November 2, 2024"
   - Time period: "24-hour summary (11/1 6:00 PM - 11/2 6:00 PM)"

2. **Summary stats:**
   ```
   DAILY SUMMARY
   Temperature: Avg 22.8°C (Min 20.2°C, Max 24.3°C) ✅
   Humidity: Avg 67% (Min 55%, Max 78%) ✅
   Soil Moisture: Avg 48% (Min 32%, Max 62%) ✅
   Light: Avg 3200 lux (Min 0 lux at night, Max 4800) ✅
   CO₂: Avg 820 ppm (Min 780, Max 860) ✅
   Air Quality: Avg 185 ppm (Min 150, Max 220) ✅
   ```

3. **Hourly readings table:**
   - Time | Temp | Humidity | Soil | Light | CO₂ | Quality
   - 6:00 PM | 22.1°C | 62% | 48% | 150 lux | 815 | 190
   - 7:00 PM | 21.8°C | 65% | 47% | 0 lux | 820 | 188
   - 8:00 PM | 21.5°C | 68% | 46% | 0 lux | 825 | 192
   - ... (continues for 24 hours)

4. **AI Recommendations section:**
   - "Temperature remained stable throughout the day - excellent"
   - "Humidity spiked to 78% at 2 PM. Window ventilation helped"
   - "Soil moisture adequate - no watering needed during this period"
   - "Light levels perfect during daylight hours"

5. **Graphs:**
   - 24-hour temperature line graph
   - 24-hour humidity line graph
   - Hourly soil moisture bar chart
   - Light intensity over time
   - Alert history timeline

6. **Footer:**
   - Generated by: EcoView v1.0
   - Data source: APEX polling service
   - Export date/time stamp

### How We Used PDF Reports

**Real usage patterns:**
1. **Weekly record-keeping:** Generated report every Sunday
2. **Sharing with team:** Emailed PDF to manager showing week's data
3. **Troubleshooting:** Looked at graphs to understand what caused an alert
4. **Documentation:** Kept folder of 4 weeks of reports for analysis

**Real report we generated:**
- Report date: Nov 2, 2024
- Time period: 24 hours
- File size: 2.4 MB
- Contents: All 10 sensors, hourly readings, graphs, AI notes
- Used for: Documented stable conditions, shared with team

---

## Settings & Configuration

### 📸 Settings Screen Screenshots

#### Screenshot 1: Settings Main Screen
**[INSERT IMAGE HERE: `docs/screenshots/19_settings_main.png`]**

**What you see when tapping ⚙️ Settings icon:**
```
⚙️ SETTINGS
═════════════════════════════════════

Backend Connection:
  ✅ Status: Connected
  Current Server: 192.168.1.100:5000

Connection Type:
  ◉ Auto-Discovery (Recommended)
  ○ Manual IP Address

[Test Connection] [Reconnect]

Preferences:
  □ Enable Notifications
  □ Show AI Recommendations
  □ Dark Mode

About:
  Version: 1.0.1
  Build: 245
  [Check for Updates]
```

**How to use settings:**
1. **Check status:** See if backend is currently connected ✅
2. **Test connection:** Verify backend is responding
3. **Switch to manual:** If auto-discovery not working
4. **Configure preferences:** Turn notifications on/off
5. **Check version:** Know which app version you have

#### Screenshot 2: Manual IP Configuration
**[INSERT IMAGE HERE: `docs/screenshots/20_settings_manual_ip.png`]**

**What you see when selecting "Manual IP Address":**
```
⚙️ SETTINGS > Manual Connection
═════════════════════════════════════

Manual Server Configuration:

Backend IP Address:
  [192.168.1.100___________________]
  (Leave blank for auto-discovery)

Port:
  [5000]

⬜ Use Custom Port (if backend uses different port)

[Test Connection]
Status: Checking... ⏳

```

**How to set manual IP:**
1. **Open Settings** → Tap ⚙️
2. **Select Manual IP** → Radio button
3. **Enter IP address** → Example: 192.168.1.100
4. **Keep port 5000** → Unless backend configured differently
5. **Tap [Test Connection]** → Wait for ✅ or ❌
6. **If ✅:** Connected! Go back to dashboard
7. **If ❌:** Try different IP or restart backend

**Finding your backend IP:**
- Open computer where backend runs
- Open terminal/PowerShell
- Type: `ipconfig`
- Look for "IPv4 Address" in your network adapter
- Use that IP in the app

#### Screenshot 3: Notifications Settings
**[INSERT IMAGE HERE: `docs/screenshots/21_settings_notifications.png`]**

**What you see:**
```
⚙️ SETTINGS > Notifications
═════════════════════════════════════

Notifications:

☑ Enable Alerts
  Receive notifications for yellow/red alerts

☑ Enable Updates
  Get notified about app updates

☑ Sound
  🔊 On

☑ Vibration
  📳 On

Alert Types:
  ☑ Critical (Red)
  ☑ Warning (Yellow)
  ☑ Info (Green when recovered)

Quiet Hours:
  From: [6:00 PM]
  To:   [7:00 AM]
  (No alerts during quiet hours)
```

**Common notification setups:**
- **Most people:** Keep all enabled
- **Night shift:** Set quiet hours (example: 9 PM - 7 AM)
- **Office use:** Disable vibration, keep sound

#### Screenshot 4: About & Version Screen
**[INSERT IMAGE HERE: `docs/screenshots/22_settings_about.png`]**

**What you see:**
```
⚙️ SETTINGS > About
═════════════════════════════════════

EcoView Greenhouse Monitor

Version: 1.0.1
Build: 245
Release Date: Nov 1, 2024

Installed: Nov 2, 2024

Backend API: v3.2
Data Format: APEX JSON

☑ Check for Updates
Status: You are up to date

[Share Feedback] [View License] [Reset App]
```

---

## Connection Issues & Fixes

### Real Issues We Encountered & Solutions

**Issue: "Connection Failed"**
```
Problem: App says backend not found
Happened: First time setup

What we did:
1. Checked backend was running:
   Terminal showed: ✅ APEX poll successful!
   
2. Verified same WiFi:
   Both on home WiFi (2.4GHz, not 5GHz)
   
3. Set IP manually:
   Settings → Backend IP → 192.168.1.100
   Pressed Test Connection → ✅ Success!
```

**Issue: "No Data on Dashboard"**
```
Problem: App connects but shows no readings
Happened: Once after restart

What we did:
1. Waited 5 seconds (APEX needs time to poll)
2. Tapped refresh icon (↻)
3. Dashboard updated ✅
```

**Issue: "Backend Won't Start"**
```
Problem: Python error when running app.py
Happened: First time (missing reportlab)

What we did:
pip install --upgrade reportlab==4.4.4
python app.py again → ✅ Started!
```

**Issue: "PDF Export Takes Forever"**
```
Problem: Seems stuck when exporting
Happened: Once during test

What we did:
1. Left it running (takes 10-15 seconds)
2. PDF appeared successfully
3. Saved to downloads
```

### How to Check if Things Work

**Backend OK?**
- Terminal shows: `✅ APEX poll successful! Got 20 readings`
- Dashboard updates every 3 seconds
- Latest data is fresh

**Network OK?**
- Both devices on same WiFi network
- Can ping each other (if on same subnet)
- No firewall blocking port 5000

---

## Daily Usage

### Real Workflow (How We Used It)

**Morning Check (2 minutes):**
1. Open app
2. Dashboard appears instantly
3. Glance at all 10 sensors - check for yellow/red
4. Everything green ✅ = Good to go

**If Alert Appears (5 minutes):**
1. Tap the alert
2. Read recommendation (AI or fallback)
3. Take action if needed (water, vent, etc.)
4. App updates automatically when fixed

**Weekly Report (3 minutes):**
1. Tap Report icon (📄)
2. Wait 10 seconds for PDF to generate
3. Click "Save" or "Share"
4. File saved with date/time

### Key Things to Remember

- ✅ **Data updates every 3 seconds** - don't refresh frantically
- ✅ **Green is good** - yellow needs monitoring - red needs action
- ✅ **AI is optional** - app works great even without it
- ✅ **Cold temps are risky** - below 18°C is critical
- ✅ **High humidity bad** - above 80% causes mold/disease

### Optimal Numbers (What We Aim For)

- 🌡️ **Temperature:** 20-25°C (narrow range keeps plants happy)
- 💧 **Humidity:** 50-70% (sweet spot for most plants)
- 🌱 **Soil:** 40-60% (well drained but moist)
- ☀️ **Light:** 2000-5000 lux (good growth light)
- �️ **CO₂:** 800-1200 ppm (normal greenhouse)

---

## FAQ (Real Questions We Had)

**Q: What if internet goes down?**  
A: App stops working (needs to reach APEX). Backend keeps local copy of last readings until internet returns.

**Q: Can I check my greenhouse remotely?**  
A: No - app only works on same WiFi network. This is current limitation.

**Q: Why doesn't it show data older than 24 hours?**  
A: Graphs show live 24h window. PDF exports capture that day's data for records.

**Q: What happens if backend crashes?**  
A: App shows "Connection Failed". Just restart: `python app.py` again.

**Q: Does AI always work?**  
A: No - it's optional. Without API key, you get fallback recommendations (still useful).

**Q: How accurate are the sensors?**  
A: ±2°C for temperature is normal. APEX data is what the physical sensors send.

---

## Quick Reference Card

| Need | Action |
|------|--------|
| **Dashboard** | Open app → Appears automatically |
| **See graph** | Tap any sensor card |
| **Export PDF** | Tap 📄 icon → Wait 10s → Save |
| **Manual IP** | Settings ⚙️ → Enter IP → Test |
| **Fix "No Data"** | Tap ↻ refresh icon or restart app |
| **Check backend** | Look at computer terminal |
| **Restart backend** | Stop Python + `python app.py` |
| **View alerts** | Tap 🔔 icon in nav |

---

<div align="center">

**🌱 This is how we monitor our greenhouse - simple and effective!**

</div>
