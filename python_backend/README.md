# Python Backend

This folder contains the Flask backend for EcoView. There are two runnable entry points:

- app.py — production backend that the Flutter app connects to by default
- Saterday testing.py — an isolated testing backend for validating APEX data and PDF export without impacting production

## app.py (production)

- Purpose: connect to Oracle APEX, normalize sensor data, provide REST APIs, and export a PDF report
- Default port: 5000
- APEX URL: set in `.env` via `ORACLE_APEX_URL`

Run:

```powershell
cd python_backend
python app.py
```

Core endpoints:
- GET /api/health
- GET /api/sensor-data
- GET /api/sensor-analysis/<sensor_type>
- GET /api/ai-recommendations
- GET /api/alerts
- GET /api/export-report

See `THRESHOLDS.md` for status bands.

## Saterday testing.py (isolated testing backend)

- Purpose: a safe copy for testing against a Saturday/Oracle APEX testing URL without touching `app.py`
- Isolation: runs as a separate Python process; does not modify or get imported by `app.py`
- Default port: 5000 (same as `app.py`) — do not run both at once on the same port
- Default APEX URL: `https://oracleapex.com/ords/at2/greenhouse/sensor` (override with `ORACLE_APEX_URL`)
- PDF export: mirrors production fixes (portrait layout, column widths, "CO2" text fix, consistent spacing)

Run:

```powershell
cd python_backend
python "Saterday testing.py"
```

To run both production and testing together, adjust one port:

```python
# at the bottom of "Saterday testing.py"
app.run(host='0.0.0.0', port=5001, debug=True)
```

## Environment and dependencies

- Create a virtual environment once and reuse for both entry points:

```powershell
cd python_backend
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

- Optional AI: set `GEMINI_API_KEY` in `.env` for AI analyses and recommendations

## Notes

- The testing backend logs APEX pull timestamps and temperatures for quick verification
- Connection pooling is used to make APEX requests faster and more reliable
- The testing backend does not affect `app.py`; stopping one does not affect the other
