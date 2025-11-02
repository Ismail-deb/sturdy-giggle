# EcoView - Quick User Manual (Realistic Setup)

## Table of Contents
1. [How We Set It Up](#how-we-set-it-up)
2. [Getting the App Running](#getting-the-app-running)
3. [Dashboard Overview](#dashboard-overview)
4. [Viewing Sensor Data](#viewing-sensor-data)
5. [Alerts & Notifications](#alerts--notifications)
6. [Generating Reports](#generating-reports)
7. [Connection Issues & Fixes](#connection-issues--fixes)
8. [Daily Usage](#daily-usage)
9. [FAQ](#faq-real-questions-we-had)
10. [Quick Reference Card](#quick-reference-card)

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
- ✅ Dashboard showing temperature, humidity, CO₂, light, soil moisture
- ✅ PDF export working with AI recommendations

---

## Getting the App Running

### Real World Scenario: This is What Happened

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

**On Your Phone/Browser:**
1. Install/build the Flutter app
2. Open the app
3. It automatically finds your backend server
4. Dashboard appears with live greenhouse data
5. **No manual setup needed** - just works! ✅

### If Auto-Discovery Doesn't Work

This happened to us when:
- Network firewall blocked UDP broadcast
- Device on different WiFi band (5GHz vs 2.4GHz)
- Backend port changed

**Solution we used:**
1. Open App → Settings
2. Manually enter backend IP: `192.168.1.100`
3. Keep port: `5000`
4. Tap "Test Connection"
5. Wait for ✅ confirmation
6. Close settings - dashboard updates

---

## Dashboard Overview

### What You See When It Works

**Live readings from APEX (every 3 seconds):**

```
🏡 EcoView Dashboard          [↻ Refresh]
═════════════════════════════════════════

Status: All Systems Normal ✅ (2 seconds ago)

┌─────────────────────────────────┐
│  🌡️ TEMPERATURE    💧 HUMIDITY   │
│  22.5°C ✅         68% ✅        │
│  (Optimal)         (Optimal)    │
│                                 │
│  🌱 SOIL MOISTURE  ☀️ LIGHT     │
│  52% ✅            4200 lux ✅  │
│  (Optimal)         (Optimal)    │
│                                 │
│  🌫️ CO₂             🔥 AIR       │
│  820 ppm ✅        185 ppm ✅   │
│  (Optimal)         (Good)       │
└─────────────────────────────────┘

⚠️ Alerts: None active


Navigation: [📊] [📈] [🤖] [ℹ️] [📄] [⚙️]
```

### Real Data Example

This is what we actually saw:
- **Temperature:** 22.5°C (perfect for plants)
- **Humidity:** 68% (ideal moisture in air)
- **Soil Moisture:** 52% (well watered)
- **Light:** 4200 lux (good growing conditions)
- **CO₂:** 820 ppm (normal greenhouse level)
- **Air Quality:** 185 ppm (good)

All green ✅ = Everything is working perfectly

### 📸 Dashboard Screenshots & How to Use Them

#### Screenshot 1: Main Dashboard Home Screen
**[INSERT IMAGE HERE: `docs/screenshots/01_dashboard_main.png`]**

**What you see:**
- Header: "🌱 EcoView - Greenhouse Monitor"
- Status bar: "✅ ALL SYSTEMS NORMAL"
- 6 cards in grid (2 columns × 3 rows):
  - Top: 🌡️ Temperature, 💧 Humidity
  - Middle: 🌱 Soil, ☀️ Light
  - Bottom: 🌫️ CO₂, 🌫️ Air Quality
- Each card shows icon, label, value, ✅ status color
- Timestamp: "✅ All readings fresh (3s ago)"

**How to interact with this screen:**
1. **Quick check:** Glance at all 6 sensors at once
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
- Large display: "22.5°C" in big font
- Subtitle: "Optimal" (or "Warning" or "Critical")
- Range indicator: "Safe 20-25°C | Alert 18-27°C | Critical <18"
- Graph: 24-hour line chart showing temperature over time
- Stats: "Min: 20.2°C | Max: 24.8°C | Avg: 22.1°C"
- AI Note: "Temperature has been stable all day - excellent growing conditions"
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
- Big number: "52%" in ✅ green
- Visual indicator: Soil moisture bar showing "halfway full"
- Status: "Optimal - Well watered"
- Range: "Safe 40-60% | Alert 30-70% | Too Dry <30% | Too Wet >80%"
- 24-hour trend: Graph showing dips (when you watered) and gradual decline
- AI Note: "Soil moisture ideal - no watering needed yet. Next watering likely in 8-12 hours"
- [Next Watering] suggestion button

**How to use:**
- **Big number:** Shows soil wetness percentage
- **Graph dips:** Each dip = when you watered plants
- **Gradual decline:** Normal - plants absorbing water
- **AI prediction:** Shows when you'll need to water again
- **Tap [Next Watering]:** Sets reminder for predicted watering time

#### Screenshot 4: Light Level Detail Screen
**[INSERT IMAGE HERE: `docs/screenshots/09_sensor_detail_light.png`]**

**What you see:**
- Big number: "4200 lux" in ✅ green
- Visual: Light bar showing "strong light"
- Status: "Excellent - Perfect for growth"
- Range: "Safe 2000-5000 | Alert 1000-2000 | Low <1000 | Too Bright >6000"
- Time-based graph: Shows light increases during day, drops at night
- Peak time: "Peak light: 2:45 PM (4500 lux)"
- AI Note: "Light levels ideal. Plants receiving optimal photosynthesis window"

**How to use:**
- **Big number:** Current light intensity in lux
- **Graph shape:** Should show peak midday, low at night
- **Peak info:** Shows best time of day for light
- **AI note:** Tells if grow lights needed or if natural light sufficient

#### Screenshot 5: CO₂ Level Detail Screen
**[INSERT IMAGE HERE: `docs/screenshots/10_sensor_detail_co2.png`]**

**What you see:**
- Big number: "820 ppm" in ✅ green
- Status: "Normal - Greenhouse level"
- Range: "Safe 800-1200 ppm | Alert 600-800 | Low <600 | High >1500"
- Trend: Shows relatively stable line
- Comparison: "Outdoor level: ~400 ppm | Your greenhouse: 820 ppm (2x enriched)"
- AI Note: "CO₂ elevated for optimal plant growth - perfect for photosynthesis"

**How to use:**
- **Big number:** CO₂ parts per million
- **Comparison:** Shows how greenhouse CO₂ compares to outdoors
- **Stable line:** Normal behavior
- **Enrichment info:** Shows plants getting extra CO₂ from respiration

#### Screenshot 6: Air Quality Detail Screen
**[INSERT IMAGE HERE: `docs/screenshots/11_sensor_detail_air_quality.png`]**

**What you see:**
- Big number: "185 ppm" in ✅ green
- Status: "Good - Clean air"
- Quality indicator: "Particulate matter low"
- Range: "<200 ppm Good | 200-300 Moderate | 300-400 Poor"
- Graph: Relatively flat line (good circulation)
- AI Note: "Air circulation excellent. No harmful particles detected"

**How to use:**
- **Big number:** Particulate matter measurement
- **Status:** Green = clean, Yellow = some particles, Red = poor
- **Flat graph:** Good - means particles dispersing
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
4. AI note: "Still adequate, no grow lights needed"
5. Decided to leave as is

**Key takeaway:**
- **Tap cards when worried** - they explain what's happening
- **Trust the AI note** - it tells you if action needed
- **Watch the graph** - rising/falling line shows trends
- **Green = ignore, Yellow = monitor, Red = act**

---

### All Sensor Ranges We Used

| Sensor | Optimal | When Concerned | Critical |
|--------|---------|---|---|
| 🌡️ Temperature | 20-25°C | 18-28°C | <18 or >28°C |
| 💧 Humidity | 50-70% | 45-75% | <45 or >80% |
| 🌱 Soil Moisture | 40-60% | 30-70% | <30 or >70% |
| ☀️ Light | 2000-5000 lux | 1000-8000 | <500 lux |
| 🌫️ CO₂ | 800-1200 | 400-1500 | >2000 ppm |
| 🔥 Air Quality | <200 | 200-500 | >500 ppm |

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

### Real Alert Examples We Saw

| Alert | Actual Reading | What We Did | Result |
|-------|---|---|---|
| High Humidity | 75% (yellow) | Opened windows | Dropped to 68% in 2 min ✅ |
| High Temperature | 27°C (yellow) | Opened roof vent | Dropped to 24°C in 3 min ✅ |
| Low Soil Moisture | 32% (yellow) | Watered plants | Rose to 52% in 5 min ✅ |
| Low Light | 1800 lux (yellow) | Checked time (was 7 AM) | Rose naturally to 4200 at noon ✅ |

### Alert Response Timing

- **Alert appears:** Within ~3 seconds of crossing threshold
- **You get notified:** Bell icon shows red dot
- **AI recommendation:** Ready to tap and read
- **Takes you to action:** [See Details] shows full sensor view
- **Auto-clears:** When value returns to safe range

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
- Contents: All 6 sensors, hourly readings, graphs, AI notes
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
3. Glance at all 6 sensors - check for yellow/red
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
