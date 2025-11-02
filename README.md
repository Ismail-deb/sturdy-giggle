# EcoView - Smart Greenhouse Monitoring System

A full-stack Flutter + Python application for real-time greenhouse environmental monitoring with AI-powered recommendations.

**Status:** Local development & testing only (not deployed to app stores)

## Quick Start

### Backend (Python Flask)

1. Install dependencies:
```powershell
cd python_backend
pip install flask flask-cors requests python-dotenv reportlab==4.4.4
```

2. Configure `.env`:
```
ORACLE_APEX_URL=https://oracleapex.com/ords/g3_data/iot/greenhouse/
GEMINI_API_KEY=your_api_key_here  # Optional
```

3. Run:
```powershell
python app.py
```
Server runs on `http://localhost:5000` and broadcasts on your local network.

### Frontend (Flutter)

1. Install Flutter & dependencies:
```powershell
cd flutter_frontend
flutter pub get
```

2. Run:
```powershell
flutter run -d chrome      # Web (fastest to test)
flutter run -d windows     # Windows desktop
flutter run -d android     # Android (requires Android Studio)
```

## Project Structure

```
├─ flutter_frontend/        # Flutter UI (Material 3, responsive dashboard)
├─ python_backend/          # Flask REST API + APEX polling
├─ scripts/                 # Helper scripts
└─ docs/                    # Documentation
```

## Key Features

- **Live Dashboard:** Temperature, humidity, soil moisture, light, CO₂, air quality
- **AI Insights:** Gemini-powered recommendations (with fallback)
- **PDF Reports:** Generate comprehensive environmental reports
- **Auto-Discovery:** Frontend finds backend automatically on local network
- **Real-Time Alerts:** Safety and environment notifications

## Architecture

- **Backend:** Flask pulls live data from Oracle APEX every 3 seconds
- **Frontend:** Flutter app connects to backend via REST API
- **AI:** Optional Google Gemini integration for smart recommendations
- **Reports:** ReportLab generates PDFs with sensor data and AI analysis

## API Endpoints

- `GET /api/health` — Status check
- `GET /api/sensor-data` — Latest readings and status
- `GET /api/ai-recommendations` — AI insights (Gemini + fallback)
- `GET /api/alerts` — Safety and environment alerts
- `GET /api/export-report` — Generate PDF report

## Troubleshooting

**Backend won't start:**
- Missing Python? Install [Python 3.10+](https://python.org)
- Missing reportlab? We upgraded to v4.4.4 (newer version with pre-built wheels). Run: `pip install --upgrade reportlab==4.4.4`

**Frontend can't find backend:**
- Verify backend is running: visit `http://localhost:5000/api/health`
- Same WiFi network? Manual IP in app Settings
- Windows Firewall? Allow port 5000

**AI recommendations not showing:**
- Optional feature. Set `GEMINI_API_KEY` in `.env` and restart backend, or app uses fallback alerts

## Known Limitations

- Local network only (no cloud deployment)
- Tested on Windows 11 with Python 3.14
- Flutter tested on Windows desktop and Chrome web
- Requires direct LAN access (no VPN/remote access yet)

## Notes for Developers

- Backend polls APEX every 3 seconds (persistent HTTP with connection pooling)
- Frontend auto-discovers backend via UDP broadcast (cached in SharedPreferences)
- AI fallback provides safety recommendations even without API key
- PDF reports include 6 top AI recommendations + sensor data + alerts

---

**Documentation:** See `USER_MANUAL.md` for feature walkthrough, `DEPLOYMENT_GUIDE.md` for local network setup.

What the backend does:

- Polls Oracle APEX every few seconds (persistent HTTP connection with pooling and gzip)
- Broadcasts its presence over UDP every 5s as `GREENHOUSE_SERVER:<ip>:5000` to help the app auto‑discover it
- Serves REST API at `http://<host>:5000/api`

### Core API Endpoints

- GET `/api/health` — status check
- GET `/api/sensor-data` — latest normalized readings + derived fields
- GET `/api/sensor-analysis/<sensor_type>` — stats and optional AI for one sensor
- GET `/api/sensor-analysis/<sensor_type>/ai` — AI analysis only
- GET `/api/ai-recommendations` — consolidated AI guidance
- GET `/api/alerts` — environment and safety alerts with severity
- GET `/api/export-report` — generate a PDF report

See `python_backend/THRESHOLDS.md` for the exact status bands used by the backend.

### Test Backend: "Saterday testing.py" (isolated)

For A/B testing or validating new Oracle APEX data without touching production, the repository includes an isolated backend at `python_backend/Saterday testing.py`.

- Purpose: points to the Saturday/APEX testing URL by default and mirrors the production routes and PDF export logic, so you can test end-to-end without changing `app.py`.
- Isolation: it runs as a separate Python process; it does not import or modify `app.py`, and nothing in `app.py` depends on it.
- Default port: 5000 (same as `app.py`). Don’t run both at the same time on the same machine unless you change one port.
- Default APEX URL: `https://oracleapex.com/ords/at2/greenhouse/sensor` (override with `ORACLE_APEX_URL` in `.env` if needed).

Run the testing backend:

```powershell
cd python_backend
# (optional) activate the same venv as production backend
.venv\Scripts\Activate.ps1
python "Saterday testing.py"
```

Notes:
- Because the testing backend uses its own file and process, stopping it has no impact on the main `app.py` server.
- If you need both to run simultaneously, start one of them on a different port (e.g., `5001`).
  You can do this by editing the last line in the file to `app.run(host='0.0.0.0', port=5001, debug=True)`.

## Frontend (Flutter) — Setup and Run

1) Install dependencies and run

```powershell
cd flutter_frontend
flutter pub get
flutter run -d windows  # or -d chrome / -d macos / -d linux / -d edge
```

2) Connecting to the backend

- Auto‑discovery: if the backend is running on the same network, the app will find it via UDP broadcast
- Manual: open Settings in the app and set the backend IP (and port if non‑default)

> Tip: On Windows, ensure Firewall allows inbound connections on port 5000.

### Dev quickstart (Windows)

You can use an automated PowerShell script that sets up Python, starts the backend, and runs Flutter.

```powershell
# From the repo root
Set-ExecutionPolicy -Scope Process RemoteSigned
./scripts/dev_quickstart.ps1               # defaults to -Device windows
./scripts/dev_quickstart.ps1 -Device chrome # run in Chrome instead
```

The script will:
- Create `.venv` in `python_backend` if missing
- Install backend requirements
- Start the Flask server in a new PowerShell window
- Run the Flutter app on Windows (or Chrome if Windows device isn’t available)

## Sensors and Optimal Ranges (Summary)

From `THRESHOLDS.md` and in‑app Sensor Info:

- Temperature: Optimal 20–27°C; Acceptable 18–20 or 27–30; Critical <18 or >30
- Humidity: Optimal 45–70%; Acceptable 71–80%; Critical <45 or >80
- Light (0–4095 raw): Dark 0–300; Low 301–819; Dim 820–1638; Moderate 1639–2457; Bright 2458+
- Air Quality (MQ135 ppm): Good ≤200; Moderate 201–500; Poor >500
- Smoke (MQ2 ppm): Safe ≤300; Elevated 301–750; High >750
- CO (MQ7 ppm): Safe ≤300; Elevated 301–750; High >750
- Soil Moisture (%): Optimal 40–60; Acceptable 30–40 or 60–70; Critical <30 or >70
- Flame: Boolean; “Flame Detected” triggers critical alert

## Theming and UI Notes

- Light theme: earthy palette (warm beige background, soil‑brown primary, olive secondary)
- Dark theme: eco‑tech green accents on deep green surfaces
- Inputs are consistently themed (TextField, Dropdown, SearchBar);
  banner uses the app icon; dashboard cards are responsive and clickable

## Troubleshooting

- Frontend can’t connect:
  - Verify backend is running and reachable at `http://<backend-ip>:5000/api/health`
  - Same LAN/Wi‑Fi? Firewall permits port 5000?
  - Set the server IP manually in the app Settings
- New asset not showing (e.g., app icon):
  - Do a Hot Restart, or stop the app and run `flutter run` again
  - `flutter clean` if still stuck, then rebuild
- AI responses missing:
  - Set `GEMINI_API_KEY` in backend `.env` and restart the server
  - The app includes robust fallback guidance if AI is unavailable

## Development Tips

- Backend: uses connection pooling to APEX; logs latest pull timestamps and temperatures for quick sanity checks
- Frontend: uses `server_discovery.dart` for UDP discovery and caches the IP in SharedPreferences
- The dashboard provides analysis and AI when you click a card; the Sensors page is for education and ranges

## Roadmap ideas

- Authentication and multi‑greenhouse support
- Push notifications and scheduled reports
- Packaging for Windows/macOS installers and Android/iOS stores

---

If you need help running the app in your environment, open an issue or ask for a tailored quickstart.

## Optional extras we can add

- Add screenshots (banner, dashboard, sensor info) to this README for visual clarity
- Provide a tiny "dev quickstart" PowerShell script that creates a virtualenv, installs Python deps, runs the backend, and launches the Flutter app on Windows

## Screenshots

Below are representative visuals. You can replace these with your own captures in `docs/screenshots/`.

- App icon (banner style)

  ![EcoView Icon](flutter_frontend/assets/app_icon.png)

- Dashboard (placeholder)

  Place a screenshot at `docs/screenshots/dashboard.png`, then replace this line with:
  `![Dashboard](docs/screenshots/dashboard.png)`

- Sensor Info (placeholder)

  Place a screenshot at `docs/screenshots/sensor-info.png`, then replace this line with:
  `![Sensor Info](docs/screenshots/sensor-info.png)`