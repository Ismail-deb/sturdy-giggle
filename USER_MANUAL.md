# EcoView Greenhouse Monitoring System - User Manual

## Table of Contents
1. [Introduction](#introduction)
2. [Getting Started](#getting-started)
3. [Dashboard Overview](#dashboard-overview)
4. [Monitoring Sensors](#monitoring-sensors)
5. [AI Recommendations](#ai-recommendations)
6. [Sensor Analysis](#sensor-analysis)
7. [Notifications & Alerts](#notifications--alerts)
8. [Reports & Export](#reports--export)
9. [Settings & Configuration](#settings--configuration)
10. [Troubleshooting](#troubleshooting)
11. [Best Practices](#best-practices)
12. [FAQ](#faq)

---

## Introduction

### What is EcoView?

EcoView is an intelligent greenhouse monitoring system that helps you maintain optimal growing conditions for your plants. The system continuously monitors:

- 🌡️ **Temperature** - Air temperature in your greenhouse
- 💧 **Humidity** - Moisture level in the air
- 🌱 **CO2 Levels** - Carbon dioxide concentration
- 🌾 **Soil Moisture** - Water content in soil
- ☀️ **Light Intensity** - Amount of light available to plants
- 🔥 **Flame Detection** - Fire safety monitoring

### Key Features

- **Real-time Monitoring**: View current conditions at a glance
- **Historical Data**: Track trends over time with interactive charts
- **AI Recommendations**: Get smart advice powered by Google Gemini AI
- **Instant Alerts**: Receive notifications when conditions are outside optimal ranges
- **Detailed Reports**: Generate PDF reports for record-keeping
- **Multi-sensor Support**: Monitor all critical parameters in one place

### System Requirements

**For Mobile App:**
- Android 7.0 or higher
- 100MB free storage
- Internet connection (WiFi or mobile data)

**For Greenhouse:**
- WiFi connection (2.4GHz)
- Sensors properly installed and connected
- Backend server running

---

## Getting Started

### 1. Installation

#### Android Installation

1. **Download the APK**
   - Obtain the `app-release.apk` file from your administrator
   - Transfer it to your Android device

2. **Enable Unknown Sources**
   - Go to Settings > Security
   - Enable "Install from Unknown Sources" or "Allow from this source"

3. **Install the App**
   - Locate the APK file using a file manager
   - Tap to install
   - Follow on-screen prompts
   - Tap "Open" when installation completes

#### iOS Installation (If Available)

1. Download from TestFlight or App Store
2. Follow standard iOS installation process

### 2. First Launch

When you first open EcoView:

1. **Grant Permissions**
   - **Internet**: Required to fetch sensor data
   - **Notifications**: Optional, for alerts
   - Tap "Allow" for each permission

2. **Check Connection**
   - The app will attempt to connect to the backend server
   - If successful, you'll see the Dashboard
   - If connection fails, see [Troubleshooting](#troubleshooting)

3. **Explore the Interface**
   - Take a moment to familiarize yourself with the navigation
   - The Dashboard is your home screen

### 3. Navigation Basics

The app has a clean, intuitive interface:

```
┌─────────────────────────┐
│   📊 Dashboard          │  ← Main screen
├─────────────────────────┤
│   📈 Sensor Details     │  ← Tap any sensor card
├─────────────────────────┤
│   🤖 AI Recommendations │  ← Smart advice
├─────────────────────────┤
│   ℹ️ Learn About Sensors│  ← Educational info
├─────────────────────────┤
│   📄 Generate Report    │  ← Export PDF
└─────────────────────────┘
```

**Navigation Tips:**
- Tap sensor cards to view detailed analysis
- Swipe down to refresh data
- Use back button to return to previous screen
- Notifications appear at the top when conditions are critical

---

## Dashboard Overview

### Understanding the Dashboard

The Dashboard is your central hub for monitoring greenhouse conditions.

#### Header Section

```
┌────────────────────────────────┐
│  🏡 EcoView Dashboard          │
│  Last Updated: 10:34 AM        │
└────────────────────────────────┘
```

- **Title**: Shows current screen name
- **Timestamp**: When data was last updated
- **Refresh Icon**: Tap to manually refresh data

#### Sensor Cards

Each sensor has its own card displaying:

1. **Sensor Icon**: Visual representation (thermometer, water drop, etc.)
2. **Sensor Name**: Type of measurement
3. **Current Value**: Latest reading
4. **Status Indicator**:
   - 🟢 **Green**: Optimal range
   - 🟡 **Yellow**: Warning - slightly outside optimal
   - 🔴 **Red**: Critical - immediate attention needed
5. **Trend Arrow**: Shows if value is increasing ↑, decreasing ↓, or stable →

#### Example Sensor Card

```
┌──────────────────────────┐
│  🌡️  Temperature         │
│                          │
│      22.5°C              │  ← Current value
│      🟢 Optimal          │  ← Status
│      ↑ +0.5°C           │  ← Trend
│                          │
│  [View Details]          │  ← Tap to analyze
└──────────────────────────┘
```

### Quick Actions

At the bottom of the Dashboard:

- **🤖 AI Recommendations**: Get intelligent advice
- **📄 Export Report**: Generate PDF summary
- **ℹ️ Learn More**: Educational information about sensors

### Reading Sensor Cards

#### Temperature Card
- **Optimal Range**: 18-28°C (64-82°F)
- **Green**: 20-26°C
- **Yellow**: 18-20°C or 26-28°C
- **Red**: Below 18°C or above 28°C

#### Humidity Card
- **Optimal Range**: 50-70%
- **Green**: 55-65%
- **Yellow**: 50-55% or 65-70%
- **Red**: Below 50% or above 70%

#### CO2 Card
- **Optimal Range**: 400-1200 ppm
- **Green**: 600-1000 ppm
- **Yellow**: 400-600 ppm or 1000-1200 ppm
- **Red**: Below 400 ppm or above 1200 ppm

#### Soil Moisture Card
- **Optimal Range**: 30-70%
- **Green**: 40-60%
- **Yellow**: 30-40% or 60-70%
- **Red**: Below 30% or above 70%

#### Light Intensity Card
- **Optimal Range**: 2000-8000 lux
- **Green**: 4000-7000 lux
- **Yellow**: 2000-4000 lux or 7000-8000 lux
- **Red**: Below 2000 lux or above 8000 lux

#### Flame Sensor Card
- **Green**: No flame detected ✓
- **Red**: Flame detected! 🔥 (Immediate action required)

### Refreshing Data

Data updates automatically every 30 seconds. To manually refresh:

1. Pull down on the Dashboard screen (pull-to-refresh gesture)
2. Or tap the refresh icon in the top-right corner
3. Watch for the loading indicator
4. Data will update when refresh completes

---

## Monitoring Sensors

### Viewing Detailed Analysis

To see detailed information about any sensor:

1. **Tap on a sensor card** from the Dashboard
2. The **Sensor Analysis Screen** opens
3. You'll see:
   - Current value with status
   - Historical chart (default: last 24 hours)
   - Time range selector
   - Chart type selector
   - AI-powered insights

### Time Range Selection

Choose how much historical data to view:

- **Last Minute**: See real-time changes (5-second intervals)
- **Last Hour**: Recent trends (1-minute intervals)
- **Last Day**: Daily patterns (hourly intervals)
- **Last Month**: Monthly trends (daily intervals)
- **Last Year (Weekly)**: Long-term patterns (weekly intervals)
- **Last Year (Monthly)**: Annual overview (monthly intervals)
- **Last 5 Years**: Multi-year comparison (yearly intervals)

**To Change Time Range:**
1. Tap the current range button (e.g., "Last Day")
2. Select desired range from the dropdown
3. Chart updates automatically

### Chart Types

EcoView offers three visualization options:

#### 1. Line Chart (Default)
```
    Temperature Over Time
    │
30°C│     ╱╲
    │    ╱  ╲    ╱
25°C│   ╱    ╲  ╱
    │  ╱      ╲╱
20°C│─────────────────
    └──────────────────
     8AM  12PM  4PM  8PM
```

**Best for**: Seeing trends and patterns over time

**Features**:
- Smooth curved lines
- Color-coded zones (green = optimal)
- Interactive - tap to see exact values
- Shows maximum, minimum, and average

#### 2. Bar Chart
```
    Humidity Levels
    │
70% │     ███
    │ ███ ███ ███
60% │ ███ ███ ███
    │ ███ ███ ███ ███
50% │ ███ ███ ███ ███
    └─────────────────
      Mon Tue Wed Thu
```

**Best for**: Comparing values across time periods

**Features**:
- Color-coded bars (green/yellow/red)
- Clear visual comparison
- Easy to spot outliers

#### 3. Area Chart
```
    CO2 Concentration
    │
1000│     ▄▀▀▄
ppm │   ▄▀▓▓▓▓▀▄
    │ ▄▀▓▓▓▓▓▓▓▓▀▄
 400│▀▀▀▀▀▀▀▀▀▀▀▀▀
    └──────────────
     Morning Evening
```

**Best for**: Visualizing volume and cumulative data

**Features**:
- Gradient fill under the line
- Shows data density
- Smooth transitions

**To Switch Chart Types:**
1. Look for chart type selector chips below the time range
2. Tap "Line", "Bar", or "Area"
3. Chart updates instantly

### Understanding Chart Colors

Charts use color-coding to show if values are in optimal ranges:

- **🟢 Green Zone**: Values within optimal range
- **🟡 Yellow Zone**: Values in warning range (acceptable but not ideal)
- **🔴 Red Zone**: Values in critical range (action needed)
- **Gray Zones**: Outside monitoring range

### AI Insights Section

Below each chart, you'll find AI-generated insights:

```
┌────────────────────────────────┐
│  🤖 AI Analysis                │
│                                 │
│  "The temperature has been     │
│  consistently high during      │
│  afternoon hours. Consider     │
│  increasing ventilation or     │
│  adding shade cloth."          │
│                                 │
│  Trend: Rising ↗               │
│  Confidence: High              │
└────────────────────────────────┘
```

**What AI Analyzes:**
- Current trends (rising, falling, stable)
- Pattern recognition (daily cycles, anomalies)
- Comparison to optimal ranges
- Contextual advice based on your data

### Statistics Summary

At the bottom of the analysis screen:

```
┌─────────────────────────────────┐
│  Statistics (Last 24 Hours)     │
│                                  │
│  Maximum:    28.5°C at 2:30 PM  │
│  Minimum:    19.2°C at 5:00 AM  │
│  Average:    23.8°C             │
│  Current:    22.5°C             │
│  Range:      9.3°C              │
└─────────────────────────────────┘
```

This helps you understand:
- **Maximum**: Highest recorded value
- **Minimum**: Lowest recorded value
- **Average**: Mean value over the period
- **Current**: Latest reading
- **Range**: Difference between max and min

---

## AI Recommendations

### Accessing AI Recommendations

From the Dashboard:
1. Tap the **"AI Recommendations"** button
2. Or tap the brain icon 🤖 in the sensor card

The AI Recommendations screen provides:
- Personalized advice based on your greenhouse conditions
- Priority-based recommendations (High, Medium, Low)
- Actionable steps to optimize your environment

### Understanding Recommendation Cards

Each recommendation card shows:

```
┌──────────────────────────────────┐
│  🌡️  TEMPERATURE                 │
│  ⚠️ High Priority                │
│                                   │
│  "Temperature exceeds optimal    │
│  range during peak hours."       │
│                                   │
│  💡 Recommendation:               │
│  • Increase ventilation          │
│  • Add shade cloth               │
│  • Monitor afternoon temps       │
│                                   │
│  Expected Impact: Medium         │
└──────────────────────────────────┘
```

#### Card Components

1. **Icon & Sensor Type**: Which sensor triggered the recommendation
2. **Priority Badge**: 
   - 🔴 **High**: Immediate action recommended
   - 🟡 **Medium**: Action within 24 hours
   - 🟢 **Low**: General optimization
3. **Problem Description**: What the AI detected
4. **Recommendations**: Specific actions to take
5. **Expected Impact**: How much this will help

### Priority Levels Explained

#### 🔴 High Priority
- **When**: Values in critical range
- **Action**: Take immediate action
- **Examples**:
  - Temperature above 30°C or below 15°C
  - Humidity below 40% or above 80%
  - Flame detected
  - Soil moisture below 20%

#### 🟡 Medium Priority
- **When**: Values in warning range
- **Action**: Address within 24 hours
- **Examples**:
  - Temperature 28-30°C or 16-18°C
  - Humidity 45-50% or 70-75%
  - CO2 above 1000 ppm
  - Light below 3000 lux

#### 🟢 Low Priority
- **When**: Minor optimizations available
- **Action**: Consider when convenient
- **Examples**:
  - Fine-tuning for better growth
  - Seasonal adjustments
  - Energy efficiency tips
  - Preventive maintenance

### Types of Recommendations

#### Temperature Management
- **Cooling**: Ventilation, shading, evaporative cooling
- **Heating**: Insulation, heaters, thermal mass
- **Circulation**: Fans, vents, air movement

#### Humidity Control
- **Increase**: Misting, humidifiers, watering
- **Decrease**: Ventilation, dehumidifiers, heating
- **Balance**: Monitoring, adjusting gradually

#### CO2 Optimization
- **Increase**: CO2 generators, composting, fermentation
- **Decrease**: Ventilation, plant density adjustment
- **Natural**: Optimal plant placement

#### Soil Moisture
- **Irrigation**: Watering schedule, drip systems
- **Drainage**: Soil improvement, raised beds
- **Monitoring**: Check soil before watering

#### Light Management
- **Increase**: Supplemental lighting, cleaning glass
- **Decrease**: Shade cloth, whitewash, blinds
- **Timing**: Photoperiod control for plants

### Refreshing Recommendations

AI recommendations update based on:
- Current sensor readings
- Recent trends
- Time of day/season
- Historical patterns

**To Refresh:**
1. Tap the refresh icon in the top-right
2. Or pull down to refresh
3. New analysis runs immediately

### No Recommendations?

If you see:
```
┌──────────────────────────────────┐
│  ✅ All Systems Optimal          │
│                                   │
│  Your greenhouse conditions are  │
│  perfect! All parameters are     │
│  within optimal ranges.          │
│                                   │
│  ✓ No action required            │
└──────────────────────────────────┘
```

**This means:**
- All sensors reading normally
- No critical issues detected
- Greenhouse is well-maintained
- Continue current practices

**Still want advice?**
- Check individual sensor analysis
- Review historical trends
- Generate a full report

---

## Sensor Analysis

### Advanced Analysis Features

Each sensor has a dedicated analysis screen with powerful features.

### Accessing Sensor Analysis

**Method 1: From Dashboard**
1. Tap any sensor card
2. Opens detailed analysis for that sensor

**Method 2: From Navigation**
1. Tap menu icon (if available)
2. Select "Sensor Analysis"
3. Choose sensor type

### Analysis Screen Layout

```
┌─────────────────────────────────┐
│  ← Temperature Analysis         │
├─────────────────────────────────┤
│  [Last Day ▼]  [Line|Bar|Area] │  ← Controls
├─────────────────────────────────┤
│                                  │
│   📊 Interactive Chart          │
│                                  │
├─────────────────────────────────┤
│  📈 Statistics                   │
│  • Max: 28.5°C                  │
│  • Min: 19.2°C                  │
│  • Avg: 23.8°C                  │
├─────────────────────────────────┤
│  🤖 AI Insights                  │
│  "Temperature patterns show..." │
└─────────────────────────────────┘
```

### Interactive Chart Features

#### Zoom and Pan
- **Pinch**: Zoom in/out on data
- **Drag**: Pan left/right through time
- **Double-tap**: Reset zoom

#### Tap for Details
- Tap any point on the chart
- See exact value and timestamp
- Popup shows:
  ```
  23.5°C
  Nov 2, 2025 2:30 PM
  Status: Optimal
  ```

#### Mobile Optimization
- Charts automatically adjust for screen size
- Axis labels optimized for readability
- No overlapping text on small screens
- Smooth scrolling

### Comparing Multiple Time Ranges

To compare different periods:

1. **Take a Screenshot** of current view
2. **Change time range** to another period
3. **Compare visually** or save both

**Example Use Case:**
- Compare "Last Day" with "Last Month"
- Identify if today's pattern is normal
- Spot seasonal changes

### Exporting Chart Data

While direct data export isn't available in the app, you can:

1. **Generate PDF Report**: Includes charts and data
2. **Take Screenshots**: For quick sharing
3. **Note Values**: Write down important readings

### Understanding Patterns

#### Daily Patterns
Look for:
- Temperature: Peak in afternoon, low at dawn
- Light: High midday, zero at night
- CO2: Low during day (plants consume), high at night
- Humidity: Often inversely related to temperature

#### Weekly Patterns
- Compare weekday vs. weekend (if greenhouse attendance varies)
- Identify days with unusual readings
- Track effects of interventions

#### Monthly/Seasonal Patterns
- Seasonal changes in light and temperature
- Heating/cooling system usage
- Plant growth cycles

#### Anomalies to Watch For
- **Sudden Spikes**: Equipment malfunction or external event
- **Gradual Drift**: Sensor calibration issue
- **Missing Data**: Connection problems
- **Flat Lines**: Sensor failure

---

## Notifications & Alerts

### Alert System Overview

EcoView continuously monitors your greenhouse and sends alerts when:
- Values enter critical range
- Rapid changes occur
- Sensors stop responding
- Fire is detected (flame sensor)

### Types of Notifications

#### Critical Alerts (🔴 Red)
```
┌────────────────────────────────┐
│  🚨 CRITICAL ALERT             │
│                                 │
│  Temperature: 32.5°C           │
│  Dangerously High!             │
│                                 │
│  Action: Increase ventilation  │
│  immediately                    │
│                                 │
│  [View Details] [Dismiss]      │
└────────────────────────────────┘
```

**When You'll See These:**
- Temperature extremes
- Very low humidity
- Flame detected
- Sensor failures
- Rapid changes

**What to Do:**
1. Tap notification to open app
2. Check sensor details
3. Take recommended action
4. Monitor until resolved

#### Warning Alerts (🟡 Yellow)
```
┌────────────────────────────────┐
│  ⚠️ WARNING                     │
│                                 │
│  Soil Moisture: 28%            │
│  Below optimal range           │
│                                 │
│  Action: Water plants soon     │
│                                 │
│  [View Details] [Dismiss]      │
└────────────────────────────────┘
```

**When You'll See These:**
- Values approaching critical
- Gradual decline in conditions
- Maintenance reminders

**What to Do:**
1. Review the alert
2. Plan corrective action within 24 hours
3. Monitor trend
4. Dismiss when addressed

#### Info Notifications (🔵 Blue)
```
┌────────────────────────────────┐
│  ℹ️ INFORMATION                 │
│                                 │
│  New AI recommendations        │
│  available                      │
│                                 │
│  [View Now] [Later]            │
└────────────────────────────────┘
```

**When You'll See These:**
- New recommendations available
- System updates
- General information
- Tips and advice

### Managing Notifications

#### Notification Settings

To adjust notification preferences:

1. Open device **Settings**
2. Navigate to **Apps** > **EcoView**
3. Tap **Notifications**
4. Configure:
   - Enable/disable notifications
   - Sound settings
   - Vibration
   - LED color (if available)
   - Lock screen visibility

#### Notification Channels (Android 8.0+)

EcoView uses separate channels for different alert types:

- **Critical Alerts**: Highest priority, bypass Do Not Disturb
- **Warnings**: Normal priority
- **Info**: Low priority

**To Customize:**
1. Settings > Apps > EcoView > Notifications
2. Tap each channel
3. Set priority, sound, vibration individually

#### Do Not Disturb Mode

**Important**: Critical alerts (flame, extreme temperature) will bypass Do Not Disturb to ensure safety.

To allow all alerts during DND:
1. Settings > Sound > Do Not Disturb
2. Tap "Priority only allows"
3. Enable "Alarms" and "Priority notifications"
4. Add EcoView to priority apps

### Notification Best Practices

#### For Home Users
- Enable all critical alerts
- Warnings during waking hours only
- Info notifications: OFF

#### For Commercial Greenhouses
- Enable all notifications
- Multiple staff members should install the app
- Consider dedicated monitoring device

#### For Remote Monitoring
- Enable all alerts with sound
- Check app regularly even without alerts
- Set up backup monitoring (email/SMS via backend)

### Troubleshooting Notifications

#### Not Receiving Notifications?

**Check 1: App Permissions**
```
Settings > Apps > EcoView > Permissions
✓ Notifications: Allowed
```

**Check 2: Battery Optimization**
```
Settings > Battery > Battery optimization
Find EcoView > Select "Don't optimize"
```

**Check 3: Background Data**
```
Settings > Apps > EcoView > Mobile data & Wi-Fi
✓ Background data: Enabled
```

**Check 4: Connection**
- Verify internet connection
- Check if app can reach backend server
- Test by refreshing dashboard

#### Too Many Notifications?

**Solution 1: Adjust Thresholds**
- Contact administrator to adjust alert thresholds
- Reduce sensitivity for non-critical sensors

**Solution 2: Notification Filtering**
- Disable info notifications
- Keep critical and warning only

**Solution 3: Consolidation**
- Backend can be configured to consolidate multiple alerts
- Only send notification every X minutes

---

## Reports & Export

### Generating PDF Reports

EcoView can generate comprehensive PDF reports containing:
- Current sensor readings
- Historical data tables
- Charts and graphs
- AI recommendations
- Sensor health status

### Creating a Report

**Step 1: Access Report Feature**
1. From Dashboard, scroll to bottom
2. Tap **"📄 Export Report"** button
3. Or tap menu > "Generate Report"

**Step 2: Wait for Generation**
```
┌────────────────────────────────┐
│  📊 Generating Report...       │
│                                 │
│  [██████████░░░░░░░░] 60%     │
│                                 │
│  Compiling sensor data...      │
└────────────────────────────────┘
```

Generation takes 10-30 seconds depending on:
- Amount of historical data
- Number of sensors
- Device speed

**Step 3: Save or Share**

When complete, you'll see:
```
┌────────────────────────────────┐
│  ✅ Report Ready               │
│                                 │
│  greenhouse_report_2025-11-02  │
│  Size: 2.4 MB                  │
│                                 │
│  [Open] [Share] [Save]         │
└────────────────────────────────┘
```

**Options:**
- **Open**: View PDF in app
- **Share**: Send via email, messaging, etc.
- **Save**: Save to device storage

### Report Contents

A typical report includes:

#### Page 1: Cover Page
- Report title
- Generation date and time
- Greenhouse name (if configured)
- Reporting period

#### Page 2: Executive Summary
```
CURRENT CONDITIONS SUMMARY

Temperature:    22.5°C    ✓ Optimal
Humidity:       58%       ✓ Optimal  
CO2:            750 ppm   ✓ Optimal
Soil Moisture:  45%       ✓ Optimal
Light:          5200 lux  ✓ Optimal
Flame:          None      ✓ Safe

Overall Status: HEALTHY
No critical issues detected.
```

#### Page 3-4: Detailed Sensor Data

For each sensor:
- Current reading
- 24-hour high/low
- 7-day average
- Status indicator
- Mini chart

#### Page 5: Historical Data Table
```
┌──────────────────────────────────────────┐
│ Timestamp    │ Temp │ Humid │ CO2 │ Soil │
├──────────────────────────────────────────┤
│ 10:00 AM     │ 22.1 │ 59    │ 745 │ 46   │
│ 11:00 AM     │ 23.5 │ 57    │ 760 │ 45   │
│ 12:00 PM     │ 24.8 │ 55    │ 780 │ 44   │
│ ...          │ ...  │ ...   │ ... │ ...  │
└──────────────────────────────────────────┘
```

#### Page 6-7: Charts and Graphs
- Temperature trend (line chart)
- Humidity trend (line chart)
- CO2 levels (area chart)
- Soil moisture (bar chart)

#### Page 8-9: Soil Moisture Management
```
SOIL MOISTURE MANAGEMENT

Current Status: OPTIMAL (45%)

✓ Soil moisture is within the ideal range

Recommendations:
• Continue current watering schedule
• Monitor for changes in drainage
• Check soil composition monthly

Next Check: Nov 3, 2025
```

#### Page 10-11: AI Recommendations

Detailed recommendations from AI analysis:
- Temperature management advice
- Humidity control suggestions
- CO2 optimization tips
- Lighting recommendations
- Overall environment assessment

#### Page 12: Appendix
- Sensor specifications
- Optimal ranges reference
- Troubleshooting tips
- Contact information

### Report Formats

#### Standard Report
- All sensors
- Last 24 hours of data
- AI recommendations included
- ~10-15 pages

#### Custom Report (If Available)
Configure:
- Date range (1 day to 1 year)
- Specific sensors
- Include/exclude AI analysis
- Chart types

### Using Reports

#### For Record Keeping
- Generate weekly/monthly reports
- Store digitally or print
- Track long-term trends
- Identify seasonal patterns

#### For Compliance
- Documentation for certifications
- Audit trail for organic farming
- Insurance documentation
- Research data

#### For Optimization
- Compare different time periods
- Evaluate interventions
- Share with agricultural experts
- Plan improvements

#### For Troubleshooting
- Document issues
- Share with technical support
- Track problem resolution
- Identify recurring problems

### Sharing Reports

#### Via Email
1. Tap "Share" on generated report
2. Select email app
3. Enter recipient
4. Add message if needed
5. Send

#### Via Cloud Storage
1. Tap "Save"
2. Choose location (Google Drive, Dropbox, etc.)
3. Select folder
4. Confirm save

#### Via Messaging
1. Tap "Share"
2. Select messaging app (WhatsApp, Telegram, etc.)
3. Choose contact or group
4. Send

#### Print Report
1. Open PDF
2. Tap share/print icon
3. Select printer (requires printer app)
4. Configure print settings
5. Print

### Report Troubleshooting

#### Report Generation Fails

**Error: "Unable to generate report"**

**Solutions:**
1. Check internet connection
2. Ensure backend server is running
3. Try again in a few minutes
4. Clear app cache (Settings > Apps > EcoView > Clear Cache)

**Error: "Insufficient data"**

**Cause**: Not enough historical data available

**Solutions:**
- Wait for more data to collect (at least 1 hour)
- System may be newly installed
- Check if sensors are connected

#### PDF Won't Open

**Solutions:**
1. Install a PDF reader app (Adobe Acrobat Reader, Google PDF Viewer)
2. Update your PDF reader app
3. Try opening in a different app
4. Re-download the report

#### Report Size Too Large

**If file is too large to email:**
1. Compress the PDF (use PDF compressor app)
2. Upload to cloud storage and share link
3. Use file transfer service (WeTransfer, etc.)

---

## Settings & Configuration

### Accessing Settings

While the main app focuses on monitoring, some configuration is available:

#### In-App Settings (If Available)
1. Tap menu icon (☰)
2. Select "Settings"
3. Configure available options

#### System Settings
1. Device Settings > Apps > EcoView
2. Permissions, storage, notifications

### Configurable Options

#### Notification Preferences
- Enable/disable notifications
- Alert sound selection
- Vibration patterns
- Notification priority

#### Display Settings
- Theme (light/dark mode - if available)
- Chart colors
- Unit preferences (°C/°F, ppm/percentage)
- Date/time format

#### Data Settings
- Refresh interval (manual vs. automatic)
- Data retention period
- Cache management
- Offline mode

#### Server Connection
- Backend server URL (usually pre-configured)
- Connection timeout
- Retry settings

### Changing Units

#### Temperature: °C ↔ °F
```
Current: 22.5°C
Convert: (22.5 × 9/5) + 32 = 72.5°F
```

#### Humidity: Percentage
- Always displayed as %
- Relative humidity (RH)

#### CO2: ppm
- Parts per million
- Standard measurement

#### Light: Lux
- Standard unit for illuminance
- 1000 lux ≈ bright indoor lighting

#### Soil Moisture: Percentage
- 0% = completely dry
- 100% = saturated

### Data Management

#### Clearing Cache

**When to Clear:**
- App running slowly
- Storage space low
- Display issues

**How to Clear:**
1. Settings > Apps > EcoView
2. Storage
3. Clear Cache (does NOT delete data)
4. Restart app

**Note**: This only clears temporary files. Your data is stored on the backend server.

#### Offline Data

EcoView requires an internet connection to:
- Fetch real-time sensor data
- Generate AI recommendations
- Create PDF reports
- Receive notifications

**Limited offline functionality:**
- View cached data (last successful fetch)
- Browse sensor information
- View saved reports

### Account & Privacy (If Implemented)

#### User Profiles
- Username/email
- Greenhouse information
- Preferences

#### Privacy Settings
- Data collection opt-out
- Analytics
- Crash reporting

#### Data Retention
- How long data is stored
- Backup frequency
- Deletion requests

### Backup & Restore

#### What's Backed Up
- Report downloads
- App preferences
- Notification settings

#### What's NOT Backed Up
- Sensor data (stored on server)
- Real-time readings
- Historical charts

#### Manual Backup
1. Generate comprehensive report
2. Save to cloud storage
3. Export settings (if available)

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: App Won't Connect to Server

**Symptoms:**
- Dashboard shows "Loading..." indefinitely
- Error message: "Unable to connect"
- No sensor data displayed

**Solutions:**

1. **Check Internet Connection**
   ```
   Settings > WiFi or Mobile Data
   - Ensure connected
   - Test by opening browser
   - Check signal strength
   ```

2. **Verify Server Status**
   - Is backend server running?
   - Ask administrator
   - Check server IP/domain

3. **Check App Permissions**
   ```
   Settings > Apps > EcoView > Permissions
   ✓ Internet: Allowed
   ✓ Network state: Allowed
   ```

4. **Clear App Cache**
   ```
   Settings > Apps > EcoView > Storage
   → Clear Cache
   → Restart app
   ```

5. **Check Firewall**
   - Disable VPN temporarily
   - Check corporate firewall
   - Ensure port 5000 is accessible

6. **Update Server URL**
   - Verify correct backend address
   - Check for typos in configuration
   - Ensure http:// or https:// prefix

#### Issue: Sensors Showing "No Data"

**Symptoms:**
- One or more sensor cards empty
- Last updated time is old
- "N/A" or "---" in values

**Solutions:**

1. **Check Hardware**
   - Are sensors powered on?
   - Check physical connections
   - Verify ESP32/Arduino is running
   - Look for sensor LED indicators

2. **Verify MQTT Connection**
   - Check ESP32 serial monitor
   - Ensure MQTT broker is running
   - Verify WiFi connection on hardware
   - Check MQTT credentials

3. **Inspect Backend Logs**
   - Look for MQTT errors
   - Check database writes
   - Verify sensor data format

4. **Test Individual Sensors**
   - Disconnect all but one sensor
   - Test if data appears
   - Add sensors back one by one
   - Identify faulty sensor

5. **Recalibrate Sensors**
   - Some sensors need periodic calibration
   - Follow manufacturer instructions
   - Update calibration values in code

#### Issue: Incorrect Sensor Readings

**Symptoms:**
- Values seem unrealistic
- Temperature always 0°C or 85°C
- Humidity stuck at 0% or 100%
- Random jumps in data

**Solutions:**

1. **Verify Sensor Placement**
   - Not in direct sunlight
   - Not near heating/cooling vents
   - Appropriate height
   - Proper ventilation around sensor

2. **Check Wiring**
   - Loose connections
   - Correct pin assignments
   - No shorts or breaks
   - Proper voltage levels

3. **Calibrate Sensors**
   ```cpp
   // In ESP32 code
   float temperature = dht.readTemperature();
   temperature = temperature + CALIBRATION_OFFSET;
   ```

4. **Replace Faulty Sensor**
   - If consistently wrong
   - Compare with known-good thermometer
   - Test with spare sensor

5. **Update Sensor Code**
   - Check for firmware updates
   - Verify correct sensor library version
   - Update conversion formulas

#### Issue: Notifications Not Working

**Symptoms:**
- No alerts received
- Notification badge not showing
- Critical alerts missed

**Solutions:**

1. **Enable Notifications**
   ```
   Settings > Apps > EcoView > Notifications
   ✓ All notifications: ON
   ✓ Critical Alerts: Priority
   ```

2. **Disable Battery Optimization**
   ```
   Settings > Battery > Battery Optimization
   Find EcoView → Don't optimize
   ```

3. **Allow Background Data**
   ```
   Settings > Apps > EcoView
   Mobile data & Wi-Fi
   ✓ Background data: ON
   ```

4. **Check Do Not Disturb**
   ```
   Settings > Sound > Do Not Disturb
   Allow priority notifications
   Add EcoView to priority apps
   ```

5. **Test Notification**
   - Temporarily create critical condition
   - Change temperature threshold
   - Verify notification appears

6. **Reinstall App**
   - Uninstall EcoView
   - Restart device
   - Reinstall from APK
   - Configure notifications again

#### Issue: Charts Not Displaying

**Symptoms:**
- Blank chart area
- Loading indicator forever
- Error message on chart

**Solutions:**

1. **Check Data Availability**
   - Need at least 2 data points
   - Verify sensor is sending data
   - Check selected time range

2. **Change Time Range**
   - Try different range
   - "Last Hour" requires more recent data
   - "Last Day" more forgiving

3. **Switch Chart Type**
   - Try Line chart
   - Then Bar chart
   - Then Area chart

4. **Clear App Cache**
   ```
   Settings > Apps > EcoView > Storage
   Clear Cache → Restart app
   ```

5. **Update App**
   - Check for app updates
   - Install latest version
   - Charts library updates

#### Issue: AI Recommendations Not Generating

**Symptoms:**
- Spinning loader forever
- Error: "Failed to generate recommendations"
- Empty recommendations screen

**Solutions:**

1. **Check Internet Connection**
   - AI requires online connection
   - Good bandwidth needed
   - Try on WiFi vs. mobile data

2. **Verify Gemini API**
   - Check API key validity
   - Confirm quota not exceeded
   - Check API status: https://status.cloud.google.com

3. **Wait and Retry**
   - API may be temporarily unavailable
   - Rate limit may be hit
   - Try again in a few minutes

4. **Check Server Logs**
   - Look for Gemini API errors
   - Verify API key configured
   - Check request format

5. **Fallback to Manual Analysis**
   - View sensor details individually
   - Check historical trends
   - Use general greenhouse guidelines

#### Issue: PDF Report Generation Fails

**Symptoms:**
- Error: "Report generation failed"
- Report incomplete
- PDF won't download

**Solutions:**

1. **Check Storage Space**
   ```
   Settings > Storage
   Ensure at least 100MB free
   ```

2. **Verify Permissions**
   ```
   Settings > Apps > EcoView > Permissions
   ✓ Storage: Allow
   ```

3. **Wait for Data**
   - Need minimum 1 hour of data
   - Check if sensors are connected
   - Verify data in database

4. **Retry Later**
   - Backend may be busy
   - Large datasets take time
   - Try during off-peak hours

5. **Reduce Report Size**
   - Shorter time range
   - Fewer sensors (if option available)
   - Exclude charts

#### Issue: App Crashes or Freezes

**Symptoms:**
- App closes unexpectedly
- Screen freezes
- Unresponsive interface

**Solutions:**

1. **Force Stop App**
   ```
   Settings > Apps > EcoView
   Force Stop → Restart app
   ```

2. **Clear App Data** (Last Resort)
   ```
   Settings > Apps > EcoView > Storage
   Clear Data (WARNING: Loses settings)
   Restart app
   ```

3. **Check Device Memory**
   ```
   Settings > Storage
   Settings > Memory
   Close other apps
   Restart device
   ```

4. **Update Android System**
   ```
   Settings > System > System Update
   Install any available updates
   ```

5. **Reinstall App**
   - Uninstall completely
   - Restart device
   - Install fresh APK
   - Reconfigure settings

### Performance Issues

#### Slow Loading

**Causes:**
- Slow internet connection
- Large amount of historical data
- Server performance

**Solutions:**
- Use WiFi instead of mobile data
- Close other apps
- Contact administrator about server

#### Battery Drain

**Causes:**
- Frequent refresh
- Background notifications
- Location services

**Solutions:**
```
Settings > Battery > EcoView
- Restrict background activity (unless need notifications)
- Optimize battery usage
- Reduce refresh frequency
```

#### High Data Usage

**Causes:**
- Frequent updates
- Large charts/reports
- Background sync

**Solutions:**
- Use WiFi when possible
- Reduce refresh frequency
- Disable background data (Settings > Apps > EcoView)

### Getting Help

#### Self-Help Resources

1. **This Manual**: Comprehensive guide
2. **In-App Help**: Tap (?) icons
3. **Learn About Sensors**: Educational information
4. **FAQs**: See [FAQ section](#faq)

#### Contacting Support

**Before Contacting:**
- Note exact error message
- Screenshot the issue
- Record steps to reproduce
- Check app version (Settings > About)

**What to Include:**
- Device model and Android version
- App version
- Screenshot of error
- Description of issue
- Steps you've already tried

**Contact Information:**
- GitHub Issues: https://github.com/Ismail-deb/sturdy-giggle/issues
- Email: [Your support email]
- Phone: [Your support phone]

---

## Best Practices

### Daily Monitoring

#### Morning Routine (Recommended)
1. **Open EcoView** first thing in morning
2. **Check Dashboard** for any red/yellow alerts
3. **Review Overnight Conditions**:
   - Did temperature drop too low?
   - Was humidity stable?
   - Any unusual changes?
4. **Take Action** on any recommendations
5. **Plan Day** based on forecasts

#### Throughout the Day
- **Check Every 2-4 Hours** if possible
- **Monitor During Extreme Weather**:
  - Very hot days
  - Cold nights
  - Storms
- **Respond to Notifications** promptly

#### Evening Check
1. **Review Daily Charts**
2. **Note Any Patterns**:
   - When was peak temperature?
   - How much did soil dry out?
3. **Adjust Settings** for overnight:
   - Heating/cooling schedules
   - Ventilation settings
4. **Check Next Day Forecast**

### Optimal Ranges Quick Reference

Keep these values in mind:

| Sensor | Optimal Range | Warning Range | Critical |
|--------|--------------|---------------|----------|
| **Temperature** | 20-26°C | 18-20°C, 26-28°C | <18°C, >28°C |
| **Humidity** | 55-65% | 50-55%, 65-70% | <50%, >70% |
| **CO2** | 600-1000 ppm | 400-600, 1000-1200 | <400, >1200 |
| **Soil Moisture** | 40-60% | 30-40%, 60-70% | <30%, >70% |
| **Light** | 4000-7000 lux | 2000-4000, 7000-8000 | <2000, >8000 |

**Tip**: Take a photo of this table for quick reference!

### Seasonal Adjustments

#### Spring
- **Increase Ventilation**: Warming weather
- **Monitor Light**: Days getting longer
- **Watch Humidity**: Spring rains affect levels
- **Prepare for Summer**: Test cooling systems

#### Summer
- **Cooling Priority**: Maximum ventilation
- **Shade Management**: Deploy shade cloth
- **Humidity Control**: May need misting
- **Frequent Monitoring**: Conditions change quickly

#### Fall
- **Transition Planning**: Gradual changes
- **Heating Prep**: Test heating before cold sets in
- **Light Supplementation**: Days shortening
- **Harvest Timing**: Monitor maturity conditions

#### Winter
- **Heating Focus**: Maintain minimum temperature
- **Humidity Watch**: Heating dries air
- **Lighting**: May need supplemental lights
- **Energy Efficiency**: Balance cost and plant needs

### Response Times

How quickly to act based on alert priority:

#### 🔴 Critical (Immediate - Within 1 Hour)
- **Temperature** >30°C or <15°C
- **Flame Detected**
- **Soil Moisture** <20%
- **Sensor Failure**

**Actions:**
- Stop what you're doing
- Go to greenhouse immediately
- Take corrective action
- Don't wait

#### 🟡 Warning (Same Day - Within 4-8 Hours)
- **Temperature** 28-30°C or 16-18°C
- **Humidity** <50% or >70%
- **CO2** >1000 ppm
- **Soil Moisture** 25-30%

**Actions:**
- Schedule time today
- Make necessary adjustments
- Monitor closely
- Plan prevention

#### 🟢 Low Priority (Within 1-2 Days)
- **Minor Optimizations**
- **Preventive Maintenance**
- **General Improvements**

**Actions:**
- Add to to-do list
- Address when convenient
- Not urgent

### Maintenance Schedule

#### Daily
- [ ] Check EcoView dashboard
- [ ] Respond to any alerts
- [ ] Visual inspection of greenhouse
- [ ] Physical check of sensors (look for damage)

#### Weekly
- [ ] Generate PDF report
- [ ] Review AI recommendations
- [ ] Clean sensor surfaces (dust affects readings)
- [ ] Check sensor wiring connections
- [ ] Test notification system

#### Monthly
- [ ] Deep dive into historical data
- [ ] Compare with previous months
- [ ] Calibrate sensors if needed
- [ ] Update sensor firmware if available
- [ ] Review and adjust thresholds
- [ ] Archive old reports

#### Seasonal (Every 3 Months)
- [ ] Full system check
- [ ] Replace aging sensors
- [ ] Update app if new version available
- [ ] Review threshold settings for season
- [ ] Consult with agricultural expert
- [ ] Plan for next season

#### Annual
- [ ] Complete sensor recalibration
- [ ] Hardware inspection and servicing
- [ ] Review full year of data
- [ ] Identify long-term trends
- [ ] Plan major improvements
- [ ] Update documentation

### Data Interpretation Tips

#### Understanding Context
- **Single Reading**: May be anomaly
- **Trend**: More reliable indicator
- **Pattern**: Most valuable information

#### Compare Across Sensors
- Temperature ↑ + Humidity ↓ = Normal
- CO2 ↓ + Light ↑ = Plants photosynthesizing
- Soil Moisture ↓ + Temperature ↑ = Need water

#### External Factors
- Weather conditions outside
- Time of day
- Seasonal changes
- Recent interventions (watering, ventilation)
- Plant growth stage

#### When to Investigate
- **Sudden Changes**: Check equipment
- **Gradual Drift**: Calibration needed
- **Cyclic Patterns**: Normal or system-induced?
- **Flat Lines**: Sensor failure

### Energy Efficiency

#### Smart Monitoring Saves Energy
- **Optimize Ventilation**: Only when needed
- **Heating/Cooling**: Based on actual temps, not schedule
- **Lighting**: Supplement only when natural light low
- **Prevent Waste**: Catch issues before they escalate

#### Cost-Effective Practices
1. **Use Data to Plan**
   - Identify peak temperature times
   - Plan ventilation accordingly
   - Avoid unnecessary heating/cooling

2. **Gradual Adjustments**
   - Small changes over time
   - Avoid shocking plants
   - Less energy than dramatic corrections

3. **Preventive Action**
   - Respond to warnings before critical
   - Cheaper than fixing damage
   - Better for plants

### Safety Guidelines

#### Electrical Safety
- Keep sensors dry
- Check for frayed wires
- Proper grounding
- Qualified electrician for mains power

#### Fire Safety
- Respond immediately to flame alerts
- Keep fire extinguisher nearby
- No flammable materials near sensors
- Regular electrical inspections

#### Chemical Safety
- CO2 monitoring prevents asphyxiation
- Proper ventilation when using chemicals
- Don't spray sensors with chemicals

#### Personal Safety
- Don't enter greenhouse if critical alerts
- Check conditions before extended work
- Take breaks in hot conditions
- Stay hydrated

---

## FAQ

### General Questions

**Q: How often does the app update sensor data?**
A: Data updates automatically every 30 seconds when the app is open. Sensors send data to the backend every 5-60 seconds (configurable).

**Q: Can I use EcoView without internet?**
A: Limited functionality. You can view cached data and saved reports, but you won't get real-time updates, AI recommendations, or new notifications.

**Q: Is my data secure?**
A: Yes. Data is transmitted over your local network or via HTTPS. No data is shared with third parties except Google Gemini AI for generating recommendations (anonymized).

**Q: Can multiple people use the same greenhouse?**
A: Yes! Install the app on multiple devices. Everyone will see the same data. (Authentication may be added in future versions.)

**Q: Does EcoView work on iPhone?**
A: Currently Android only. iOS version may be developed based on demand.

**Q: How much data does the app use?**
A: Approximately 5-10 MB per day with normal usage. PDF reports are 2-5 MB each. Charts and images use more data than text.

### Technical Questions

**Q: What sensors are supported?**
A: Currently:
- DHT22 (temperature & humidity)
- MQ-135 (CO2/air quality)
- Capacitive soil moisture sensors
- LDR (light sensor)
- Flame detection module

Additional sensors can be added with custom code.

**Q: Can I add more sensors?**
A: Yes, but requires:
1. Additional hardware connections
2. ESP32 code modifications
3. Backend endpoint updates
4. App updates (for display)

Consult developer documentation.

**Q: What's the sensor accuracy?**
A: Typical accuracy:
- Temperature: ±0.5°C
- Humidity: ±2%
- CO2: ±50 ppm (needs calibration)
- Soil Moisture: ±5%
- Light: ±10%

Accuracy depends on sensor quality and calibration.

**Q: How long is data stored?**
A: By default, indefinitely (limited by database size). Can be configured to auto-delete old data. Recommend keeping at least 1 year for seasonal analysis.

**Q: Can I export raw data (CSV)?**
A: Not directly in current version. PDF reports include data tables. Raw database access requires backend access.

**Q: What happens if power goes out?**
A: 
- Sensors stop reporting
- App shows last known values
- Data collection resumes when power restored
- Gap in historical charts
- Consider UPS (backup battery) for critical applications

**Q: Can I control devices (heaters, fans)?**
A: Current version is monitoring only. Control features (actuators) can be added with additional hardware and software development.

### Troubleshooting Questions

**Q: Why are my readings inconsistent?**
A: Possible causes:
- Loose wire connections
- Sensor needs calibration
- Placement issue (direct sunlight, airflow)
- Interference from other electronics
- Sensor reaching end of life

**Q: The app says "Server not found"**
A: 
1. Verify backend server is running
2. Check IP address/domain configuration
3. Ensure firewall allows connection
4. Test network connectivity
5. Restart backend server

**Q: AI recommendations are generic**
A: AI needs time to learn patterns. More specific recommendations come after:
- Collecting more data (at least 24 hours)
- Establishing baseline patterns
- Detecting anomalies from normal

**Q: Notifications delayed?**
A: May be due to:
- Battery optimization (disable for app)
- Background data restriction (enable)
- Slow internet connection
- Server processing load

**Q: Charts show gaps**
A: Gaps indicate:
- Sensor disconnected temporarily
- MQTT connection lost
- Backend server offline
- Power outage

Check logs for timestamp of gaps to identify cause.

### Cost & Maintenance Questions

**Q: What's the total cost to set up?**
A: Approximate costs:
- ESP32: $10-15
- Sensors: $50-100 (complete set)
- Wiring/breadboard: $20
- Power supply: $10
- Case/enclosure: $15
- Total hardware: ~$100-150

Plus:
- Server (can use old computer or Raspberry Pi)
- Mobile device (your existing phone)

**Q: Monthly operating costs?**
A: 
- Electricity: ~$5/month
- Internet: (existing connection)
- Gemini API: Free tier sufficient for personal use
- MQTT broker: Free (self-hosted) or $5-10/month (cloud)

**Q: How long do sensors last?**
A: Typical lifespan:
- DHT22: 2-3 years
- MQ-135: 1-2 years (degrades over time)
- Soil moisture: 1-2 years (corrosion)
- LDR: 5+ years
- Flame sensor: 3-5 years

Replace when readings become unreliable.

**Q: Can I build this myself?**
A: Yes! Full documentation available:
- Hardware guide: See DEPLOYMENT_GUIDE.md
- Software: Open source on GitHub
- Support: Community forums

Basic electronics and programming knowledge helpful but not required.

### Feature Requests

**Q: Will you add [feature X]?**
A: Feature requests welcome! Submit via:
- GitHub Issues
- Email to development team
- User feedback form (if available)

Popular requests prioritized for future versions.

**Q: Can I customize thresholds?**
A: Currently set in backend configuration. Contact administrator. Future version may include in-app threshold customization.

**Q: Multiple greenhouse support?**
A: Not in current version. Workaround: Run separate backend instances for each greenhouse. Future: Multi-greenhouse dashboard planned.

**Q: Integration with smart home (Alexa, Google Home)?**
A: Not yet. Potential future feature. Can be developed using existing API.

---

## Glossary of Terms

**API (Application Programming Interface)**: Software connection allowing app to communicate with backend server.

**Backend**: Server software that collects sensor data, runs AI analysis, and serves data to the mobile app.

**CO2 (Carbon Dioxide)**: Gas monitored for plant health. Too low = poor growth. Too high = inefficient.

**Dashboard**: Main screen showing all sensor readings at a glance.

**DHT22**: Common temperature and humidity sensor.

**ESP32**: Microcontroller board (like tiny computer) that connects sensors to WiFi.

**Frontend**: The mobile app you see and interact with.

**Lux**: Unit measuring light intensity. 1000 lux = bright office light.

**MQTT**: Communication protocol for sending sensor data from hardware to backend.

**Optimal Range**: Ideal values for best plant growth and health.

**PDF (Portable Document Format)**: File format for reports that looks same on any device.

**ppm (Parts Per Million)**: Unit for measuring CO2 concentration.

**Real-time**: Current, live data (vs. historical).

**Sensor**: Device that measures physical conditions (temperature, humidity, etc.).

**Threshold**: Boundary value that triggers alerts (e.g., temperature >30°C).

**Widget**: Visual component in the app (e.g., sensor card, chart).

---

## Quick Start Checklist

For new users, follow this checklist:

### Week 1: Setup & Familiarization
- [ ] Install app on mobile device
- [ ] Grant all necessary permissions
- [ ] Connect to backend server
- [ ] View Dashboard and understand sensor cards
- [ ] Tap each sensor to explore detailed view
- [ ] Try different chart types and time ranges
- [ ] Generate your first PDF report
- [ ] Check AI recommendations
- [ ] Enable notifications
- [ ] Test alert by creating warning condition

### Week 2: Establish Baselines
- [ ] Monitor daily for 7 days
- [ ] Note normal temperature pattern
- [ ] Understand humidity fluctuations
- [ ] Observe CO2 levels during day/night
- [ ] Track soil moisture decline rate
- [ ] Measure light intensity variations
- [ ] Record any manual interventions (watering, etc.)
- [ ] Compare weekday vs weekend patterns
- [ ] Generate end-of-week report
- [ ] Identify any issues or anomalies

### Month 1: Optimization
- [ ] Review AI recommendations regularly
- [ ] Implement suggested improvements
- [ ] Fine-tune alert thresholds (with admin)
- [ ] Establish monitoring routine
- [ ] Calibrate sensors if needed
- [ ] Create monthly report for records
- [ ] Share report with team/family
- [ ] Plan any equipment upgrades
- [ ] Join user community (if available)
- [ ] Provide feedback to developers

### Ongoing: Mastery
- [ ] Monitor daily (5 minutes)
- [ ] Respond to alerts promptly
- [ ] Weekly deep dive (15 minutes)
- [ ] Monthly reports and analysis
- [ ] Seasonal adjustments
- [ ] Share knowledge with other growers
- [ ] Contribute to documentation
- [ ] Request features you need

---

## Support & Feedback

### Getting Additional Help

**Documentation:**
- This User Manual
- DEPLOYMENT_GUIDE.md (for technical setup)
- README.md (project overview)
- GitHub Wiki (if available)

**Community Support:**
- GitHub Discussions: Ask questions, share tips
- User Forum: Connect with other greenhouse operators
- Video Tutorials: Watch setup and usage guides

**Professional Support:**
- Email: [support email]
- Phone: [support phone]
- Response time: 24-48 hours
- Priority support available for commercial users

### Providing Feedback

Your feedback helps improve EcoView!

**Bug Reports:**
- GitHub Issues: https://github.com/Ismail-deb/sturdy-giggle/issues
- Include: Screenshots, steps to reproduce, device info

**Feature Requests:**
- GitHub Discussions or Issues
- Describe use case and expected behavior
- Community votes on popular requests

**Success Stories:**
- Share how EcoView helped you
- Photos of your greenhouse
- Tips for other users

### Contributing

EcoView is open source! Contribute by:
- Improving documentation
- Reporting bugs
- Suggesting features
- Submitting code (if developer)
- Translating to other languages
- Creating video tutorials

---

## Conclusion

### You're Now Ready!

Congratulations! You now have comprehensive knowledge of:
- ✅ How to install and set up EcoView
- ✅ Reading and interpreting sensor data
- ✅ Using AI recommendations effectively
- ✅ Generating reports and exporting data
- ✅ Troubleshooting common issues
- ✅ Following best practices

### Next Steps

1. **Start Monitoring**: Open app and check dashboard daily
2. **Establish Routine**: Morning and evening checks
3. **Learn Patterns**: Understand your greenhouse's normal behavior
4. **Take Action**: Respond to recommendations
5. **Keep Records**: Generate monthly reports
6. **Optimize**: Continuous improvement based on data

### Remember

- **Data is Your Friend**: More data = better insights
- **Trends > Single Readings**: Look for patterns
- **Act on Alerts**: That's why they're there
- **Don't Panic**: Most issues have simple solutions
- **Ask for Help**: Community and support available

### Happy Growing! 🌱

With EcoView, you have professional-grade greenhouse monitoring at your fingertips. Use this data to:
- Grow healthier plants
- Increase yields
- Save resources
- Prevent problems
- Achieve better results

Thank you for choosing EcoView!

---

**Document Version**: 1.0.0  
**Last Updated**: November 2, 2025  
**Applicable to**: EcoView v1.0.0+  
**For Updates**: Check GitHub repository

**Questions?**  
📧 Email: [support email]  
🌐 Web: https://github.com/Ismail-deb/sturdy-giggle  
💬 Community: [forum link]

---

*This manual is part of the EcoView Greenhouse Monitoring System documentation suite. For technical deployment information, see DEPLOYMENT_GUIDE.md.*
