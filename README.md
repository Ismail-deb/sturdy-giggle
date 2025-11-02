<div align="center"># EcoView - Smart Greenhouse Monitoring System



# 🌱 EcoView - Smart Greenhouse MonitoringA full-stack Flutter + Python application for real-time greenhouse environmental monitoring with AI-powered recommendations.



**Real-time Environmental Monitoring with AI-Powered Intelligence****Status:** Local development & testing only (not deployed to app stores)



![Status](https://img.shields.io/badge/Status-Local%20Development-blue)## Quick Start

![Python](https://img.shields.io/badge/Python-3.10%2B-green)

![Flutter](https://img.shields.io/badge/Flutter-3.35%2B-blue)### Backend (Python Flask)

![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Mac%20%7C%20Linux-lightgrey)

1. Install dependencies:

[Features](#-features) • [Quick Start](#-quick-start) • [Architecture](#-architecture) • [Docs](#-documentation)```powershell

cd python_backend

</div>pip install flask flask-cors requests python-dotenv reportlab==4.4.4

```

---

2. Configure `.env`:

## 📊 Dashboard Overview```

ORACLE_APEX_URL=https://oracleapex.com/ords/g3_data/iot/greenhouse/

Monitor your greenhouse in real-time with live sensor data:GEMINI_API_KEY=your_api_key_here  # Optional

```

```

┌─────────────────────────────────────────────────────────┐3. Run:

│  🌡️  Temperature    💧 Humidity    🌱 Soil Moisture     │```powershell

│  22.5°C (Optimal)   65% (Optimal)  52% (Optimal)       │python app.py

│                                                         │```

│  ☀️  Light          🌫️  CO₂         🔥 Air Quality       │Server runs on `http://localhost:5000` and broadcasts on your local network.

│  4200 lux           820 ppm         185 ppm (Good)     │

│                                                         │### Frontend (Flutter)

│  ⚠️  Alerts: All systems normal                         │

└─────────────────────────────────────────────────────────┘1. Install Flutter & dependencies:

``````powershell

cd flutter_frontend

---flutter pub get

```

## ✨ Features

2. Run:

### 📈 Live Monitoring```powershell

- **Real-time Dashboards** – See all sensor readings at a glanceflutter run -d chrome      # Web (fastest to test)

- **Multi-Sensor Support** – Temperature, humidity, soil moisture, light, CO₂, air qualityflutter run -d windows     # Windows desktop

- **Historical Charts** – Track 24-hour trends and patternsflutter run -d android     # Android (requires Android Studio)

- **Status Indicators** – Green (optimal) → Yellow (alert) → Red (critical)```



### 🤖 AI Intelligence## Project Structure

- **Gemini-Powered Recommendations** – Smart analysis of greenhouse conditions

- **Automatic Fallback** – Suggestions even without API key```

- **Safety Alerts** – Flame detection, temperature warnings, air quality monitoring├─ flutter_frontend/        # Flutter UI (Material 3, responsive dashboard)

├─ python_backend/          # Flask REST API + APEX polling

### 📄 Reports & Export├─ scripts/                 # Helper scripts

- **PDF Generation** – Comprehensive environmental reports└─ docs/                    # Documentation

- **Sensor Summary** – Current readings + 6 AI recommendations```

- **Timestamp Tracking** – Documented records for analysis

## Key Features

### 🔌 Smart Discovery

- **Auto-Discovery** – App finds backend automatically on local network- **Live Dashboard:** Temperature, humidity, soil moisture, light, CO₂, air quality

- **Manual Override** – Set IP manually in Settings if needed- **AI Insights:** Gemini-powered recommendations (with fallback)

- **Connection Status** – Real-time health checks- **PDF Reports:** Generate comprehensive environmental reports

- **Auto-Discovery:** Frontend finds backend automatically on local network

---- **Real-Time Alerts:** Safety and environment notifications



## 🚀 Quick Start## Architecture



### Backend Setup (Python Flask)- **Backend:** Flask pulls live data from Oracle APEX every 3 seconds

- **Frontend:** Flutter app connects to backend via REST API

```powershell- **AI:** Optional Google Gemini integration for smart recommendations

# Navigate to backend- **Reports:** ReportLab generates PDFs with sensor data and AI analysis

cd python_backend

## API Endpoints

# Install dependencies

pip install flask flask-cors requests python-dotenv reportlab==4.4.4- `GET /api/health` — Status check

- `GET /api/sensor-data` — Latest readings and status

# Create .env file- `GET /api/ai-recommendations` — AI insights (Gemini + fallback)

# ORACLE_APEX_URL=https://oracleapex.com/ords/g3_data/iot/greenhouse/- `GET /api/alerts` — Safety and environment alerts

# GEMINI_API_KEY=your_api_key_here  (optional)- `GET /api/export-report` — Generate PDF report



# Run the server## Troubleshooting

python app.py

```**Backend won't start:**

- Missing Python? Install [Python 3.10+](https://python.org)

✅ Server running on `http://localhost:5000`- Missing reportlab? We upgraded to v4.4.4 (newer version with pre-built wheels). Run: `pip install --upgrade reportlab==4.4.4`



### Frontend Setup (Flutter)**Frontend can't find backend:**

- Verify backend is running: visit `http://localhost:5000/api/health`

```powershell- Same WiFi network? Manual IP in app Settings

# Navigate to frontend- Windows Firewall? Allow port 5000

cd flutter_frontend

**AI recommendations not showing:**

# Get dependencies- Optional feature. Set `GEMINI_API_KEY` in `.env` and restart backend, or app uses fallback alerts

flutter pub get

## Known Limitations

# Run on Chrome (fastest)

flutter run -d chrome- Local network only (no cloud deployment)

- Tested on Windows 11 with Python 3.14

# Or Windows desktop- Flutter tested on Windows desktop and Chrome web

flutter run -d windows- Requires direct LAN access (no VPN/remote access yet)



# Or build Android APK## Notes for Developers

flutter build apk --release

```- Backend polls APEX every 3 seconds (persistent HTTP with connection pooling)

- Frontend auto-discovers backend via UDP broadcast (cached in SharedPreferences)

✅ App will auto-discover backend on your network!- AI fallback provides safety recommendations even without API key

- PDF reports include 6 top AI recommendations + sensor data + alerts

---

---

## 🏗️ Architecture

**Documentation:** See `USER_MANUAL.md` for feature walkthrough, `DEPLOYMENT_GUIDE.md` for local network setup.

```

┌─────────────────────────────────────────────────────────┐What the backend does:

│                                                         │

│  📱 Flutter Frontend (UI)                               │- Polls Oracle APEX every few seconds (persistent HTTP connection with pooling and gzip)

│  ├─ Dashboard (Temperature, Humidity, CO₂, Light)      │- Broadcasts its presence over UDP every 5s as `GREENHOUSE_SERVER:<ip>:5000` to help the app auto‑discover it

│  ├─ Sensor Analysis (24hr graphs)                      │- Serves REST API at `http://<host>:5000/api`

│  ├─ AI Recommendations                                 │

│  └─ Alert Notifications                                │### Core API Endpoints

│                                                         │

└────────────────────┬────────────────────────────────────┘- GET `/api/health` — status check

                     │ HTTP/REST- GET `/api/sensor-data` — latest normalized readings + derived fields

                     ▼- GET `/api/sensor-analysis/<sensor_type>` — stats and optional AI for one sensor

┌─────────────────────────────────────────────────────────┐- GET `/api/sensor-analysis/<sensor_type>/ai` — AI analysis only

│                                                         │- GET `/api/ai-recommendations` — consolidated AI guidance

│  🐍 Flask Backend (API)                                 │- GET `/api/alerts` — environment and safety alerts with severity

│  ├─ APEX Polling (every 3 seconds)                     │- GET `/api/export-report` — generate a PDF report

│  ├─ Data Processing                                    │

│  ├─ AI Analysis (Gemini)                               │See `python_backend/THRESHOLDS.md` for the exact status bands used by the backend.

│  └─ PDF Report Generation                              │

│                                                         │### Test Backend: "Saterday testing.py" (isolated)

└────────────────────┬────────────────────────────────────┘

                     │For A/B testing or validating new Oracle APEX data without touching production, the repository includes an isolated backend at `python_backend/Saterday testing.py`.

        ┌────────────┴────────────┐

        ▼                         ▼- Purpose: points to the Saturday/APEX testing URL by default and mirrors the production routes and PDF export logic, so you can test end-to-end without changing `app.py`.

    APEX DB                  Gemini AI- Isolation: it runs as a separate Python process; it does not import or modify `app.py`, and nothing in `app.py` depends on it.

  (Sensors)          (Recommendations)- Default port: 5000 (same as `app.py`). Don’t run both at the same time on the same machine unless you change one port.

```- Default APEX URL: `https://oracleapex.com/ords/at2/greenhouse/sensor` (override with `ORACLE_APEX_URL` in `.env` if needed).



---Run the testing backend:



## 🔌 API Endpoints```powershell

cd python_backend

| Endpoint | Method | Description |# (optional) activate the same venv as production backend

|----------|--------|-------------|.venv\Scripts\Activate.ps1

| `/api/health` | GET | Server status check |python "Saterday testing.py"

| `/api/sensor-data` | GET | Latest sensor readings |```

| `/api/ai-recommendations` | GET | AI-powered suggestions |

| `/api/alerts` | GET | Active alerts & warnings |Notes:

| `/api/export-report` | GET | Generate PDF report |- Because the testing backend uses its own file and process, stopping it has no impact on the main `app.py` server.

- If you need both to run simultaneously, start one of them on a different port (e.g., `5001`).

---  You can do this by editing the last line in the file to `app.run(host='0.0.0.0', port=5001, debug=True)`.



## 📁 Project Structure## Frontend (Flutter) — Setup and Run



```1) Install dependencies and run

sturdy-giggle/

├── 📂 flutter_frontend/          # Mobile/Web UI```powershell

│   ├── lib/cd flutter_frontend

│   │   ├── main.dart              # App entry + themingflutter pub get

│   │   ├── screens/               # Dashboard, sensors, settingsflutter run -d windows  # or -d chrome / -d macos / -d linux / -d edge

│   │   └── services/              # API client, discovery```

│   └── pubspec.yaml

│2) Connecting to the backend

├── 📂 python_backend/             # REST API Server

│   ├── app.py                     # Flask app + routes- Auto‑discovery: if the backend is running on the same network, the app will find it via UDP broadcast

│   ├── gemini_service.py          # AI integration- Manual: open Settings in the app and set the backend IP (and port if non‑default)

│   ├── requirements.txt

│   └── .env                       # Config (create this)> Tip: On Windows, ensure Firewall allows inbound connections on port 5000.

│

├── 📄 README.md                   # This file### Dev quickstart (Windows)

├── 📄 USER_MANUAL.md              # App usage guide

└── 📄 DEPLOYMENT_GUIDE.md         # Detailed setupYou can use an automated PowerShell script that sets up Python, starts the backend, and runs Flutter.

```

```powershell

---# From the repo root

Set-ExecutionPolicy -Scope Process RemoteSigned

## ⚙️ Configuration./scripts/dev_quickstart.ps1               # defaults to -Device windows

./scripts/dev_quickstart.ps1 -Device chrome # run in Chrome instead

### Backend (.env file)```



```envThe script will:

# Required- Create `.venv` in `python_backend` if missing

ORACLE_APEX_URL=https://oracleapex.com/ords/g3_data/iot/greenhouse/- Install backend requirements

- Start the Flask server in a new PowerShell window

# Optional - for AI recommendations- Run the Flutter app on Windows (or Chrome if Windows device isn’t available)

GEMINI_API_KEY=sk-... 

## Sensors and Optimal Ranges (Summary)

# Server

HOST=0.0.0.0From `THRESHOLDS.md` and in‑app Sensor Info:

PORT=5000

```- Temperature: Optimal 20–27°C; Acceptable 18–20 or 27–30; Critical <18 or >30

- Humidity: Optimal 45–70%; Acceptable 71–80%; Critical <45 or >80

### Frontend (Auto-Discovery)- Light (0–4095 raw): Dark 0–300; Low 301–819; Dim 820–1638; Moderate 1639–2457; Bright 2458+

- Air Quality (MQ135 ppm): Good ≤200; Moderate 201–500; Poor >500

1. **Automatic** – App finds backend via UDP broadcast- Smoke (MQ2 ppm): Safe ≤300; Elevated 301–750; High >750

2. **Manual** – Go to Settings → Enter backend IP- CO (MQ7 ppm): Safe ≤300; Elevated 301–750; High >750

3. **Test** – Tap "Test Connection" to verify- Soil Moisture (%): Optimal 40–60; Acceptable 30–40 or 60–70; Critical <30 or >70

- Flame: Boolean; “Flame Detected” triggers critical alert

---

## Theming and UI Notes

## 🌡️ Sensor Ranges

- Light theme: earthy palette (warm beige background, soil‑brown primary, olive secondary)

| Sensor | Optimal | Acceptable | Critical |- Dark theme: eco‑tech green accents on deep green surfaces

|--------|---------|-----------|----------|- Inputs are consistently themed (TextField, Dropdown, SearchBar);

| 🌡️ Temperature | 20-25°C | 18-27°C | <18 or >28°C |  banner uses the app icon; dashboard cards are responsive and clickable

| 💧 Humidity | 50-70% | 45-75% | <45 or >80% |

| 🌱 Soil Moisture | 40-60% | 30-70% | <30 or >70% |## Troubleshooting

| ☀️ Light | 2000-5000 lux | 1000-8000 lux | <500 or >8000 |

| 🌫️ CO₂ | 800-1200 ppm | 400-1500 ppm | >2000 ppm |- Frontend can’t connect:

| 🔥 Air Quality | <200 ppm | 200-500 ppm | >500 ppm |  - Verify backend is running and reachable at `http://<backend-ip>:5000/api/health`

  - Same LAN/Wi‑Fi? Firewall permits port 5000?

---  - Set the server IP manually in the app Settings

- New asset not showing (e.g., app icon):

## 🐛 Troubleshooting  - Do a Hot Restart, or stop the app and run `flutter run` again

  - `flutter clean` if still stuck, then rebuild

### Backend Won't Start- AI responses missing:

  - Set `GEMINI_API_KEY` in backend `.env` and restart the server

```bash  - The app includes robust fallback guidance if AI is unavailable

# Check Python is installed

python --version## Development Tips



# Install reportlab correctly (key fix for Python 3.14)- Backend: uses connection pooling to APEX; logs latest pull timestamps and temperatures for quick sanity checks

pip install --upgrade reportlab==4.4.4- Frontend: uses `server_discovery.dart` for UDP discovery and caches the IP in SharedPreferences

- The dashboard provides analysis and AI when you click a card; the Sensors page is for education and ranges

# Check port 5000 is free

netstat -ano | findstr :5000## Roadmap ideas

```

- Authentication and multi‑greenhouse support

### Frontend Can't Connect- Push notifications and scheduled reports

- Packaging for Windows/macOS installers and Android/iOS stores

```bash

# Verify backend is running---

curl http://localhost:5000/api/health

If you need help running the app in your environment, open an issue or ask for a tailored quickstart.

# Check network

# ✅ Same WiFi? Both on 2.4GHz (not 5GHz)## Optional extras we can add

# ✅ Firewall? Allow port 5000

# ✅ Manual IP? Settings → Backend IP- Add screenshots (banner, dashboard, sensor info) to this README for visual clarity

- Provide a tiny "dev quickstart" PowerShell script that creates a virtualenv, installs Python deps, runs the backend, and launches the Flutter app on Windows

# If still failing, set IP manually in app Settings

```## Screenshots



### APEX Data Not LoadingBelow are representative visuals. You can replace these with your own captures in `docs/screenshots/`.



```bash- App icon (banner style)

# Check .env configuration

# Verify ORACLE_APEX_URL is correct  ![EcoView Icon](flutter_frontend/assets/app_icon.png)

# Check internet connection (APEX must be reachable)

- Dashboard (placeholder)

# View backend logs - watch terminal output

# Look for: "✅ APEX poll successful!"  Place a screenshot at `docs/screenshots/dashboard.png`, then replace this line with:

```  `![Dashboard](docs/screenshots/dashboard.png)`



### AI Recommendations Missing- Sensor Info (placeholder)



- ✅ Optional feature (app works without it)  Place a screenshot at `docs/screenshots/sensor-info.png`, then replace this line with:

- 🔧 Set `GEMINI_API_KEY` in `.env` and restart backend  `![Sensor Info](docs/screenshots/sensor-info.png)`
- 📋 Or use automatic fallback recommendations

---

## ⚠️ Known Limitations

- 🌐 **Local Network Only** – No cloud deployment (local WiFi)
- 👤 **Single User** – Not designed for concurrent users  
- 🔐 **No Authentication** – Works on trusted networks only
- 📍 **Direct LAN Access** – No VPN/remote access yet
- 🪟 **Windows Firewall** – May block port 5000 (allow manually)

---

## 🔧 Developer Notes

- Backend polls APEX every 3 seconds with connection pooling
- Frontend uses UDP broadcast for auto-discovery
- AI fallback provides safety alerts even without API key
- PDF reports include full sensor data + top 6 recommendations
- Tested on Windows 11 with Python 3.14 & Flutter 3.35.7

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| [**USER_MANUAL.md**](USER_MANUAL.md) | 👤 How to use the app |
| [**DEPLOYMENT_GUIDE.md**](DEPLOYMENT_GUIDE.md) | 🛠️ Setup & troubleshooting |
| [**DOCUMENTATION_README.md**](DOCUMENTATION_README.md) | 📖 Docs overview |

---

## 🔄 System Status

```
Backend:  ✅ Running on 0.0.0.0:5000
APEX:     ✅ Polling every 3 seconds (20+ readings/poll)
Frontend: ✅ Auto-discovering backend
AI:       ✅ Ready (with fallback recommendations)
```

---

<div align="center">

### 🌿 Built for Smart Greenhouse Management

**Monitoring • Intelligence • Reports**

Created for IFS325 Group Project - ARC Smart Agriculture  
[GitHub](https://github.com/Ismail-deb/sturdy-giggle) • [Report Issues](https://github.com/Ismail-deb/sturdy-giggle/issues)

</div>
