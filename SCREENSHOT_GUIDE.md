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
    - 🌡️ Temperature: 24.5°C ✅
    - 💧 Humidity: 58% ✅
    - 🌱 Soil Moisture: 52% ✅
    - ☀️ Light: 497 (Moderate) ✅
    - 🌫️ Air Quality (CO₂): 437 ppm ✅
    - 🔥 Flammable Gas (MQ2): 334 ppm ⚠️
    - 🌬️ Carbon Monoxide (MQ7): 54 ppm ✅
    - 📍 Pressure: 1010.68 hPa ✅
    - ☁️ CO₂ Level: 700 ppm ✅
    - ⬆️ Altitude: 0.21 m ✅
  - Bottom navigation: 🔔 📊 📄 ⚙️
- **Instruction:** "Tap any card to see detailed view, 24-hour graph, and AI analysis"

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
  - Display: "497" (raw sensor value) showing "Moderate" status in green
  - Visual light bar indicator
  - Status: "Moderate - Good for growth ✅"
  - Threshold ranges (inverted scale - lower = brighter):
    - 0-250: Bright ☀️
    - 251-650: Moderate 🌤️
    - 651-950: Dim Indoor 🏠
    - 951-1250: Dark Indoor 🌑
    - >1250: Dark Night 🌃
  - 24-hour graph showing daily cycle (low during day, high at night)
  - Stats: "Today's Min: 112 (Bright) | Max: 1450 (Dark Night) | Current: 497"
  - AI analysis: "Light level adequate for photosynthesis. Sensor uses inverted scale where lower numbers indicate brighter conditions."

#### 9. CO₂ Level Detail Screen
**File:** `docs/screenshots/09_sensor_detail_co2.png`
- **Location:** After tapping CO₂ card (Air Quality card)
- **Content to capture:**
  - Display: "700 ppm" in green (calculated from MQ135 sensor)
  - Calculation shown: "CO₂ = 400 + (MQ135 × 1.2)"
  - Status: "Good air quality ✅"
  - Range thresholds:
    - 300-800 ppm: Good (green) 🟢
    - 800-1500 ppm: Acceptable (yellow) 🟡
    - <300 or >1500 ppm: High (red) 🔴
  - Comparison: "Outdoor baseline: 400 ppm | Your greenhouse: 700 ppm"
  - 24-hour trend line showing variations
  - Stats: "Min: 520 ppm | Max: 890 ppm | Avg: 685 ppm"
  - AI analysis: "CO₂ level within optimal range for photosynthesis. Calculated from MQ135 air quality sensor readings. Good ventilation balance."

#### 10. Air Quality Detail Screen
**File:** `docs/screenshots/10_sensor_detail_air_quality.png`
- **Location:** After tapping Air Quality card (same as CO₂ card - shows co2_level)
- **Content to capture:**
  - Display: "437 ppm" in green (calculated CO₂ level)
  - Status: "Good - Clean air ✅"
  - Quality indicator with color-coded zones:
    - 🟢 Green: 300-800 ppm (Good)
    - 🟡 Yellow: 800-1500 ppm (Acceptable)
    - 🔴 Red: <300 or >1500 ppm (Action needed)
  - Calculation note: "Based on MQ135 sensor: CO₂ = 400 + (sensor_value × 1.2)"
  - 24-hour trend line (stable within green zone)
  - Stats: "Min: 412 ppm | Max: 623 ppm | Avg: 485 ppm"
  - AI analysis: "Air quality excellent with CO₂ levels supporting healthy plant growth. Sensor calibrated to greenhouse baseline of 400 ppm. Ventilation working effectively."

#### 11. Flammable Gas (MQ2) Detail Screen
**File:** `docs/screenshots/11_sensor_detail_flammable_gas.png`
- **Location:** After tapping Flammable Gas card
- **Content to capture:**
  - Display: "334 ppm" in yellow (slightly elevated)
  - Status: "Elevated - Monitor ⚠️"
  - Safety indicator with color-coded zones:
    - 🟢 Green: ≤300 ppm (Safe)
    - 🟡 Yellow: 301-750 ppm (Elevated - Monitor)
    - 🔴 Red: >750 ppm (High - Action Required)
  - 24-hour trend line (MQ2 sensor readings)
  - Stats: "Min: 285 ppm | Max: 412 ppm | Current: 334 ppm"
  - AI analysis: "Flammable gas reading slightly above safe threshold. Check heating equipment and ensure proper ventilation. Monitor for increases. Normal for greenhouses with gas heaters."

#### 12. Carbon Monoxide (MQ7) Detail Screen
**File:** `docs/screenshots/12_sensor_detail_carbon_monoxide.png`
- **Location:** After tapping Carbon Monoxide card
- **Content to capture:**
  - Display: "54 ppm" in green
  - Status: "Safe - No CO hazard ✅"
  - Safety indicator with color-coded zones:
    - 🟢 Green: ≤300 ppm (Safe)
    - 🟡 Yellow: 301-750 ppm (Elevated - Check equipment)
    - 🔴 Red: >750 ppm (Dangerous - Ventilate immediately)
  - 24-hour trend line (MQ7 sensor readings)
  - Stats: "Min: 42 ppm | Max: 68 ppm | Avg: 54 ppm"
  - AI analysis: "Carbon monoxide levels well within safe range. All combustion equipment functioning properly. Continue monitoring if using gas heaters or equipment."

#### 13. Pressure Detail Screen
**File:** `docs/screenshots/13_sensor_detail_pressure.png`
- **Location:** After tapping Pressure card
- **Content to capture:**
  - Display: "1010.68 hPa" in green
  - Status: "Normal atmospheric pressure ✅"
  - Pressure indicator with color-coded zones:
    - 🟢 Green: 990-1030 hPa (Normal)
    - 🟡 Yellow: 980-990 or 1030-1040 hPa (Unusual)
    - 🔴 Red: <980 or >1040 hPa (Extreme weather)
  - 24-hour pressure trend line (shows weather patterns)
  - Stats: "Min: 1008.2 hPa | Max: 1012.5 hPa | Avg: 1010.3 hPa"
  - Weather prediction: "Stable pressure - fair weather expected"
  - AI analysis: "Barometric pressure normal for this elevation. Stable conditions indicate continued fair weather. Monitor for rapid changes which may signal incoming weather systems."

#### 14. CO₂ Level Detail Screen
**File:** `docs/screenshots/14_sensor_detail_co2.png`
- **Location:** After tapping CO₂ Level card (duplicate of Air Quality card)
- **Content to capture:**
  - Display: "700 ppm" in green (calculated value)
  - Status: "Optimal greenhouse level ✅"
  - Calculation formula shown: "CO₂ = 400 + (MQ135_drop × 1.2)"
  - Range thresholds:
    - 300-800 ppm: Good (supports photosynthesis) 🟢
    - 800-1500 ppm: Acceptable 🟡
    - <300 or >1500 ppm: Action needed 🔴
  - Comparison: "Outdoor baseline: 400 ppm | Your greenhouse: 700 ppm"
  - 24-hour trend line showing daily fluctuations
  - Stats: "Min: 520 ppm | Max: 890 ppm | Avg: 685 ppm"
  - AI analysis: "CO₂ enrichment excellent for plant growth. Level stays within optimal photosynthesis range. Good balance between ventilation and CO₂ retention."

#### 15. Altitude Detail Screen
**File:** `docs/screenshots/15_sensor_detail_altitude.png`
- **Location:** After tapping Altitude card
- **Content to capture:**
  - Display: "0.21 m" in green
  - Status: "Reference elevation ✅"
  - Description: "Altitude calculated from BMP280 pressure sensor for accurate atmospheric readings"
  - Elevation context: "Sea level reference: 0 m | Your greenhouse: 0.21 m"
  - Static reference information (stable value - doesn't change frequently)
  - Relationship explanation: "Pressure and altitude are inversely related - used to calibrate pressure readings"
  - Stats: "Stable: 0.18-0.24 m (normal sensor variation)"
  - AI analysis: "Altitude locked at ground level for accurate barometric pressure calculations. Minor variations are normal sensor fluctuations."

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
1. Tap each sensor card (Temperature, Humidity, Soil, Light, CO₂, Air Quality, Flammable Gas, Carbon Monoxide, Pressure, Altitude)
2. Screen shows detailed view with 24-hour graph and current reading
3. **AI Analysis:** Each card includes Gemini AI-powered analysis
   - Real-time interpretation of sensor values
   - Contextual recommendations based on thresholds
   - Trend analysis and predictions
4. **Important Notes:**
   - Light sensor uses inverted scale (0-250 = Bright, >1250 = Dark Night)
   - CO₂ is calculated: `CO₂ = 400 + (MQ135_drop × 1.2)`
   - All values are real sensor data from Oracle APEX backend
   - Gemini API key must be configured in `.env` for AI analysis
5. Capture full screen showing value, status, graph, and AI insights
6. Name by sensor type

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
│   ├── 11_sensor_detail_flammable_gas.png
│   ├── 12_sensor_detail_carbon_monoxide.png
│   ├── 13_sensor_detail_pressure.png
│   ├── 14_sensor_detail_co2_level.png
│   ├── 15_sensor_detail_altitude.png
│   ├── 16_dashboard_yellow_alert.png
│   ├── 17_alerts_panel_full.png
│   ├── 18_critical_alert.png
│   ├── 19_multiple_alerts.png
│   ├── 20_report_generating.png
│   ├── 21_report_ready.png
│   ├── 22_report_preview.pdf (or .png)
│   ├── 23_settings_main.png
│   ├── 24_settings_manual_ip.png
│   ├── 25_settings_notifications.png
│   └── 26_settings_about.png
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

## Key Updates Reflected in Screenshots

### ✅ Recent Fixes Implemented (Nov 3, 2025)
- **Gemini AI Integration:** All sensor detail screens now show real AI analysis (not fallback messages)
  - API configured with `models/gemini-2.5-flash`
  - Environment variable `GEMINI_API_KEY` properly loaded from `.env`
  
- **CO₂ Calculation Fixed:** Air Quality/CO₂ cards display calculated values
  - Formula: `CO₂ = 400 + (MQ135_drop × 1.2)`
  - Example: MQ135 reading of 250 → 700 ppm CO₂
  - No longer shows 0 in AI analysis
  
- **Light Thresholds Updated:** Light sensor now uses corrected inverted scale
  - 0-250: Bright ☀️ (green)
  - 251-650: Moderate 🌤️ (green)
  - 651-950: Dim Indoor 🏠 (yellow)
  - 951-1250: Dark Indoor 🌑 (yellow)
  - \>1250: Dark Night 🌃 (red)
  - Lower numbers = Brighter conditions
  
- **All 10 Cards Documented:** Complete coverage of dashboard sensors
  - Temperature, Humidity, Soil Moisture, Light
  - Air Quality (CO₂), Flammable Gas, Carbon Monoxide
  - Pressure, CO₂ Level (duplicate), Altitude

### 📸 Screenshot Requirements
- Show **real sensor values** from Oracle APEX backend
- Include **AI analysis text** generated by Gemini API
- Display **correct status colors** based on updated thresholds
- Capture **24-hour trend graphs** for each sensor
- Ensure **10 cards visible** on main dashboard

---

## Notes

- All images should be **PNG format** for best quality and file size
- Recommended **resolution:** 1080×1920 px (mobile) or equivalent 16:9 ratio
- **Dark mode vs Light mode:** Capture in the theme you prefer (note in comments)
- **Real data:** All screenshots show actual app with real sensor values from testing
- **Consistency:** Use same device/resolution for all screenshots where possible
- **AI Analysis:** Requires valid Gemini API key in `python_backend/.env`
- **CO₂ Display:** Ensure MQ135 sensor has non-zero readings for realistic CO₂ calculations

---

**Created:** November 2, 2025  
**Updated:** November 3, 2025 - Reflected Gemini AI fix, CO₂ calculation fix, and light threshold updates
