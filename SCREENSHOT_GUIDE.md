# UI Screenshot & Image Guide

## Overview

The `USER_MANUAL_QUICK.md` includes **24 image placeholders** with detailed descriptions of each UI screen. The dashboard displays **10 sensor cards** in a responsive grid layout. This guide shows where to place each screenshot.

---

## Screenshot Locations & Descriptions

### Dashboard Screenshots (4 images)

#### 1. Main Dashboard with Green Status
**File:** `docs/screenshots/01_dashboard_main.png`
- **Location:** Show top-level app view
- **Content to capture:**
  - App header: "🌱 EcoView - Greenhouse Monitor"
  - Status bar: "✅ ALL SYSTEMS NORMAL"
  - 10 sensor cards in responsive grid layout:
    - 🌡️ Temperature: 28.9°C ✅
    - 💧 Humidity: 43.5% ✅
    - 🌱 Soil Moisture: 36% ✅
    - ☀️ Light: 1133 lux ✅
    - 🌫️ Air Quality (MQ135): 0 ppm ✅
    - 🔥 Flammable Gas (MQ2): 0 ppm ✅
    - 🌬️ Carbon Monoxide (MQ7): 0 ppm ✅
    - 📍 Pressure: 1005 hPa ✅
    - ☁️ CO₂: 400 ppm ✅
    - ⬆️ Altitude: 5.8 m ✅
  - Bottom navigation: 🔔 📊 📄 ⚙️
- **Instruction:** "Tap any card to see detailed view and 24-hour graph"

#### 2. Dashboard with Yellow Alert
**File:** `docs/screenshots/02_dashboard_with_alert.png`
- **Location:** Same as screenshot 1 but with one sensor yellow
- **Content to capture:**
  - One card (e.g., Humidity) is **YELLOW background**
  - Shows 75% humidity (above optimal)
  - Other 9 cards still green
  - Bell icon 🔔 has red notification dot
  - Text: "⚠️ 1 Alert Active"
- **Instruction:** "Tap 🔔 bell to see alert details"

#### 3. Dashboard with Multiple Alerts
**File:** `docs/screenshots/03_dashboard_multi_alert.png`
- **Location:** Show 2-3 sensors in yellow
- **Content to capture:**
  - Multiple yellow cards (Humidity, Temperature, Soil)
  - Bell icon shows number "3️⃣"
  - Each card shows warning reading
- **Instruction:** "Address critical alerts first (red), then yellow"

#### 4. Navigation Bar Close-up
**File:** `docs/screenshots/04_navigation_bar.png`
- **Location:** Bottom of screen, zoomed in
- **Content to capture:**
  - 4 navigation icons clearly visible:
    - 🔔 Alerts
    - 📊 Analytics
    - 📄 Reports
    - ⚙️ Settings
- **Instruction:** "Most used: 🔔 for alerts, 📄 for reports"

---

### Detailed Sensor Views (10 images)

#### 5. Temperature Detail Screen
**File:** `docs/screenshots/05_sensor_detail_temperature.png`
- **Location:** Screen after tapping Temperature card
- **Content to capture:**
  - Large temperature: "22.5°C" in green
  - Status: "Optimal ✅"
  - Range indicators:
    - Safe: 20-25°C (green zone)
    - Alert: 18-27°C (yellow zone)
    - Critical: <18°C or >28°C (red zone)
  - 24-hour graph line (flat/stable)
  - Stats: "Min: 20.2°C | Max: 24.3°C | Avg: 22.8°C"
  - AI note: "Temperature stable - excellent conditions"
  - Back button

#### 6. Humidity Detail Screen
**File:** `docs/screenshots/06_sensor_detail_humidity.png`
- **Location:** After tapping Humidity card
- **Content to capture:**
  - Large display: "68%" in green
  - Status: "Optimal ✅"
  - Safe range: 50-70%
  - 24-hour graph
  - Stats: "Min: 55% | Max: 78%"
  - AI note about humidity levels
  - Visual humidity bar indicator

#### 7. Soil Moisture Detail Screen
**File:** `docs/screenshots/07_sensor_detail_soil.png`
- **Location:** After tapping Soil card
- **Content to capture:**
  - Display: "52%" in green
  - Visual soil moisture bar (halfway full)
  - Status: "Well watered ✅"
  - Range: 40-60% optimal
  - 24-hour graph showing dips (when watered)
  - AI prediction: "Next watering needed in 8-12 hours"
  - [Next Watering] button

#### 8. Light Level Detail Screen
**File:** `docs/screenshots/08_sensor_detail_light.png`
- **Location:** After tapping Light card
- **Content to capture:**
  - Display: "4200 lux" in green
  - Visual light bar (strong light)
  - Status: "Perfect for growth ✅"
  - Range: 2000-5000 lux optimal
  - Daytime graph (peaks at midday, low at night)
  - Peak info: "Peak light: 2:45 PM (4500 lux)"
  - AI note about photosynthesis

#### 9. CO₂ Level Detail Screen
**File:** `docs/screenshots/09_sensor_detail_co2.png`
- **Location:** After tapping CO₂ card
- **Content to capture:**
  - Display: "820 ppm" in green
  - Status: "Greenhouse level ✅"
  - Range: 800-1200 ppm safe
  - Comparison: "Outdoor: 400 ppm | Your greenhouse: 820 ppm (2x)"
  - Stable trend line
  - AI note: "Enriched CO₂ for optimal photosynthesis"

#### 10. Air Quality Detail Screen
**File:** `docs/screenshots/10_sensor_detail_air_quality.png`
- **Location:** After tapping Air Quality card
- **Content to capture:**
  - Display: "0 ppm" in green
  - Status: "Excellent - Clean air ✅"
  - Quality indicator showing low particulates
  - Range: <200 ppm (good)
  - Flat/stable trend line (MQ135 sensor)
  - AI note: "Air circulation excellent"

#### 11. Flammable Gas (MQ2) Detail Screen
**File:** `docs/screenshots/11_sensor_detail_flammable_gas.png`
- **Location:** After tapping Flammable Gas card
- **Content to capture:**
  - Display: "0 ppm" in green
  - Status: "Safe - No flammable gas detected ✅"
  - Safety indicator showing safe zone
  - Range: <300 ppm (safe), 300-750 ppm (yellow), >750 ppm (critical red)
  - Flat/stable trend line (MQ2 sensor)
  - AI note: "All flammable gas sensors reading normal"

#### 12. Carbon Monoxide (MQ7) Detail Screen
**File:** `docs/screenshots/12_sensor_detail_carbon_monoxide.png`
- **Location:** After tapping Carbon Monoxide card
- **Content to capture:**
  - Display: "0 ppm" in green
  - Status: "Safe - No CO detected ✅"
  - Safety indicator showing safe zone
  - Range: <300 ppm (safe), 300-750 ppm (yellow), >750 ppm (critical red)
  - Flat/stable trend line (MQ7 sensor)
  - AI note: "Carbon monoxide levels normal and safe"

#### 13. Pressure Detail Screen
**File:** `docs/screenshots/13_sensor_detail_pressure.png`
- **Location:** After tapping Pressure card
- **Content to capture:**
  - Display: "1005 hPa" in green
  - Status: "Normal atmospheric pressure ✅"
  - Pressure reference indicator (normal range ~1010-1020 hPa)
  - 24-hour pressure trend line
  - Stats: "Min: 1002 hPa | Max: 1008 hPa"
  - AI note: "Stable pressure conditions"

#### 14. CO₂ Level Detail Screen
**File:** `docs/screenshots/14_sensor_detail_co2.png`
- **Location:** After tapping CO₂ card
- **Content to capture:**
  - Display: "400 ppm" in green
  - Status: "Optimal greenhouse level ✅"
  - Range: 800-1200 ppm enriched (greenhouse), 400 ppm (outdoor reference)
  - Comparison: "Outdoor: 400 ppm | Your greenhouse: 400 ppm"
  - Trend line showing stability
  - AI note: "CO₂ level supports photosynthesis"

#### 15. Altitude Detail Screen
**File:** `docs/screenshots/15_sensor_detail_altitude.png`
- **Location:** After tapping Altitude card
- **Content to capture:**
  - Display: "5.8 m" in green
  - Status: "Reference elevation ✅"
  - Description: "Altitude used for pressure calculations"
  - Static reference information (does not change frequently)
  - Pressure and altitude relationship explanation
  - AI note: "Altitude locked for accurate readings"

---

### Alert Screens (4 images)

#### 16. Yellow Alert on Dashboard
**File:** `docs/screenshots/16_dashboard_yellow_alert.png`
- **Location:** Main dashboard view
- **Content to capture:**
  - Humidity card: "75%" in YELLOW
  - Alert message on dashboard
  - Bell icon with red dot
- **Instruction:** "Yellow = Monitor, not emergency"

#### 17. Alerts Panel - Full Details
**File:** `docs/screenshots/17_alerts_panel_full.png`
- **Location:** After tapping 🔔 bell icon
- **Content to capture:**
  - Full alert information:
    - "⚠️ HUMIDITY ALERT"
    - "Current: 75%"
    - "Target: 50-70%"
    - "Status: Monitor Required"
  - Recommendation box with action text
  - Buttons: [Dismiss] [See Details] [Take Action]
  - Resolved alerts section below

#### 13. Critical Red Alert
**File:** `docs/screenshots/18_critical_alert.png`
- **Location:** When sensor reaches critical level
- **Content to capture:**
  - Dashboard card: RED background
  - Large "🔴" critical indicator
  - Message: "CRITICAL ALERT - IMMEDIATE ACTION REQUIRED"
  - Temperature: "15°C 🔴" (too cold)
  - Urgent recommendation: "Turn on heating immediately!"
  - [⚡ ACTIVATE HEATING] button (prominent)
  - FLASHING or bright red visual treatment

#### 14. Multiple Alerts View
**File:** `docs/screenshots/19_multiple_alerts.png`
- **Location:** Alerts panel with 2-3 active alerts
- **Content to capture:**
  - Stacked alert cards:
    - Alert 1: Humidity 76%
    - Alert 2: Temperature 27°C
    - Alert 3: Soil 35%
  - Each showing recommendation
  - Alert count badge: "3️⃣"
  - All with action buttons visible

---

### Report Screens (3 images)

#### 20. Report Generation Progress
**File:** `docs/screenshots/20_report_generating.png`
- **Location:** Screen shown while generating PDF
- **Content to capture:**
  - "GENERATING GREENHOUSE REPORT" title
  - Progress steps:
    - ✓ Collecting 24-hour data
    - ⏳ Calculating trends
    - Generating PDF
    - Compressing file
  - "Please wait 10-15 seconds" message
  - Spinner/progress indicator

#### 21. Report Ready to Download
**File:** `docs/screenshots/21_report_ready.png`
- **Location:** After PDF generation complete
- **Content to capture:**
  - "✅ REPORT GENERATED SUCCESSFULLY"
  - File info: "Greenhouse_Report_Nov2_2024.pdf"
  - Size: "2.4 MB"
  - Generated timestamp
  - Action buttons:
    - [📥 Download]
    - [📤 Share]
    - [📧 Email]

#### 22. PDF Report Preview
**File:** `docs/screenshots/22_report_preview.pdf`
- **Location:** Open a generated PDF file
- **Content to capture:**
  - Report header with title and date
  - Daily summary stats table:
    - Temperature avg/min/max
    - Humidity avg/min/max
    - Soil, Light, CO₂, Air Quality summaries
  - Hourly readings data table
  - 24-hour trend graphs/charts
  - AI recommendations section
  - Alert history if any

---

### Settings Screens (4 images)

#### 23. Settings Main Screen
**File:** `docs/screenshots/23_settings_main.png`
- **Location:** After tapping ⚙️ Settings icon
- **Content to capture:**
  - Settings title and layout
  - Backend Connection section:
    - Status: "✅ Connected"
    - Current Server: "192.168.1.100:5000"
  - Connection Type options:
    - ◉ Auto-Discovery (selected)
    - ○ Manual IP Address
  - Buttons: [Test Connection] [Reconnect]
  - Preferences section with toggles
  - Version info at bottom

#### 24. Manual IP Configuration
**File:** `docs/screenshots/24_settings_manual_ip.png`
- **Location:** Settings screen with Manual IP selected
- **Content to capture:**
  - "Manual Server Configuration" header
  - Input fields:
    - Backend IP: [192.168.1.100_____]
    - Port: [5000]
  - Checkbox: "Use Custom Port"
  - [Test Connection] button
  - Status display area (for ✅ or ❌)

#### 25. Notifications Settings
**File:** `docs/screenshots/25_settings_notifications.png`
- **Location:** Settings > Notifications subsection
- **Content to capture:**
  - Toggle switches:
    - ☑ Enable Alerts
    - ☑ Enable Updates
    - ☑ Sound
    - ☑ Vibration
  - Alert Types checkboxes:
    - ☑ Critical (Red)
    - ☑ Warning (Yellow)
    - ☑ Info (Green recovered)
  - Quiet Hours time pickers:
    - From: [6:00 PM]
    - To: [7:00 AM]

#### 26. About & Version
**File:** `docs/screenshots/26_settings_about.png`
- **Location:** Settings > About section
- **Content to capture:**
  - App name and logo
  - Version: "1.0.1"
  - Build: "245"
  - Release date
  - Install date
  - Backend API version
  - "Check for Updates" with status
  - Buttons: [Share Feedback] [View License] [Reset App]

---

## How to Create These Screenshots

### For Dashboard & Main Screens
1. Run `flutter run -d chrome` (web) or Windows desktop
2. Open app to main dashboard
3. Use Chrome DevTools to capture full height
4. Save as PNG with date/number

### For Sensor Detail Screens
1. Tap each sensor card (Temperature, Humidity, Soil, Light, CO₂, Air Quality)
2. Screen shows detailed view with graph
3. Capture full screen
4. Name by sensor type

### For Alert Screens
1. Modify APEX polling data to simulate:
   - Yellow alert: Set humidity to 75%
   - Red alert: Set temperature to 15°C
   - Multiple: Modify 3 sensors
2. Capture alert states
3. Open alerts panel and capture full view

### For Report Screens
1. Tap 📄 Reports icon
2. Wait for PDF generation
3. Capture progress screen during generation
4. Capture ready screen
5. Open PDF and capture preview

### For Settings Screens
1. Tap ⚙️ Settings icon
2. Capture main settings screen
3. Scroll to each section
4. Switch Manual IP option, capture
5. Navigate to Notifications, About, capture each

---

## File Organization

### Suggested Directory Structure

```
docs/
├── screenshots/
│   ├── 01_dashboard_main.png
│   ├── 02_dashboard_with_alert.png
│   ├── 03_dashboard_multi_alert.png
│   ├── 04_navigation_bar.png
│   ├── 05_sensor_detail_temperature.png
│   ├── 06_sensor_detail_humidity.png
│   ├── 07_sensor_detail_soil.png
│   ├── 08_sensor_detail_light.png
│   ├── 09_sensor_detail_co2.png
│   ├── 10_sensor_detail_air_quality.png
│   ├── 11_dashboard_yellow_alert.png
│   ├── 12_alerts_panel_full.png
│   ├── 13_critical_alert.png
│   ├── 14_multiple_alerts.png
│   ├── 15_report_generating.png
│   ├── 16_report_ready.png
│   ├── 17_report_preview.pdf (or .png)
│   ├── 18_settings_main.png
│   ├── 19_settings_manual_ip.png
│   ├── 20_settings_notifications.png
│   └── 21_settings_about.png
└── README.md
```

---

## Next Steps

1. **Capture Screenshots:** Use the descriptions above to capture each screen from the running app
2. **Organize Files:** Create `docs/screenshots/` directory and save all images
3. **Update Image Paths:** Replace `[INSERT IMAGE HERE: ...]` with actual markdown image links:
   ```markdown
   ![Dashboard](docs/screenshots/01_dashboard_main.png)
   ```
4. **Test Display:** View in GitHub to ensure images render correctly
5. **Commit:** Add images and updated manual to git

---

## Notes

- All images should be **PNG format** for best quality and file size
- Recommended **resolution:** 1080×1920 px (mobile) or equivalent 16:9 ratio
- **Dark mode vs Light mode:** Capture in the theme you prefer (note in comments)
- **Real data:** All screenshots show actual app with real sensor values from testing
- **Consistency:** Use same device/resolution for all screenshots where possible

---

**Created:** November 2, 2025  
**Updated:** For USER_MANUAL_QUICK.md v1.0
