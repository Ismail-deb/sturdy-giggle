# 🚀 Render Deployment - Quick Reference

## One-Command Deploy Checklist

### 1. Push to GitHub
```bash
git add .
git commit -m "Deploy to Render"
git push origin main
```

### 2. Render Dashboard Setup
```
📍 URL: https://dashboard.render.com
1. New + → Web Service
2. Connect: Ismail-deb/sturdy-giggle
3. Root Directory: python_backend
4. Build Command: pip install -r requirements.txt
5. Start Command: gunicorn app:app --bind 0.0.0.0:$PORT --workers 2 --threads 4 --timeout 120
```

### 3. Environment Variables (Required)
```
ORACLE_APEX_URL=https://oracleapex.com/ords/g3_data/iot/greenhouse/
ORACLE_APEX_SOIL_URL=https://oracleapex.com/ords/g3_data/groups/data/10
ORACLE_APEX_POLL_INTERVAL=3
GEMINI_API_KEY=your_key_here
FLASK_ENV=production
PYTHON_VERSION=3.11.0
```

### 4. Test Your Deployment
```bash
# Replace YOUR_APP_NAME with your actual Render app name
curl https://YOUR_APP_NAME.onrender.com/api/health
curl https://YOUR_APP_NAME.onrender.com/api/sensor-data
```

## 📱 Update Flutter App

**File:** `flutter_frontend/lib/services/api_service.dart`

```dart
static const String baseUrl = 'https://YOUR_APP_NAME.onrender.com/api';
```

## 🎯 Render URL Structure

```
Base URL: https://YOUR_APP_NAME.onrender.com

Endpoints:
├── /api/health              (Health check)
├── /api/sensor-data         (Latest sensor readings)
├── /api/alerts              (Active alerts)
├── /api/thresholds          (GET/POST thresholds)
├── /api/sensor-analysis/<sensor_type>
└── /api/sensor-analysis/<sensor_type>/ai
```

## ⚡ Free Tier Limits

- ✅ 750 hours/month free
- ⏱️ Sleeps after 15 min inactivity
- 🔄 ~30s to wake up on first request
- 💾 No persistent disk storage

## 🔧 Troubleshooting

**App won't start?**
- Check logs in Render Dashboard
- Verify all environment variables are set
- Ensure ORACLE_APEX_URL is accessible

**503 Errors?**
- Free tier sleeps - first request wakes it up
- Check APEX endpoints are responding
- Review backend logs for polling errors

**Want 24/7 uptime?**
- Upgrade to Render paid plan ($7/month)
- Or use a cron job to ping health check every 10 minutes

## 📞 Quick Links

- Dashboard: https://dashboard.render.com
- Docs: https://render.com/docs
- Status: https://status.render.com

---

**Your deployed backend will be at:**
```
https://ecoview-backend.onrender.com
```
(or whatever name you choose)
