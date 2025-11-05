# 🚀 Deploy EcoView Backend to Render

This guide will help you deploy the EcoView Flask backend to Render.com (similar to your existing deployment).

## 📋 Prerequisites

1. A [Render.com](https://render.com) account (free tier available)
2. Your GitHub repository pushed to GitHub
3. Oracle APEX URLs for sensor data
4. Google Gemini API key (optional, for AI analysis)

## 🔧 Files Created for Deployment

The following files have been created in the `python_backend` folder:

- ✅ `render.yaml` - Render configuration file
- ✅ `Procfile` - Process file for starting the app
- ✅ `runtime.txt` - Python version specification
- ✅ `build.sh` - Build script
- ✅ `requirements.txt` - Updated with all dependencies including `google-generativeai`

## 📝 Step-by-Step Deployment

### 1️⃣ Push Your Code to GitHub

```bash
cd c:\Users\griff\Downloads\sturdy-giggle\sturdy-giggle-1
git add .
git commit -m "Add Render deployment configuration"
git push origin main
```

### 2️⃣ Create a New Web Service on Render

1. Go to [https://dashboard.render.com](https://dashboard.render.com)
2. Click **"New +"** → **"Web Service"**
3. Connect your GitHub repository (`Ismail-deb/sturdy-giggle`)
4. Configure the service:

   **Basic Settings:**
   - **Name:** `ecoview-backend` (or any name you prefer)
   - **Region:** Choose closest to you (e.g., Oregon, Frankfurt)
   - **Branch:** `main`
   - **Root Directory:** `python_backend`
   - **Runtime:** `Python 3`
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `gunicorn app:app --bind 0.0.0.0:$PORT --workers 2 --threads 4 --timeout 120`

   **Plan:**
   - Select **Free** (or paid plan for better performance)

### 3️⃣ Add Environment Variables

In the Render dashboard, go to **"Environment"** tab and add these variables:

| Key | Value | Description |
|-----|-------|-------------|
| `PYTHON_VERSION` | `3.11.0` | Python runtime version |
| `ORACLE_APEX_URL` | `https://oracleapex.com/ords/g3_data/iot/greenhouse/` | Main sensor data endpoint |
| `ORACLE_APEX_SOIL_URL` | `https://oracleapex.com/ords/g3_data/groups/data/10` | Soil moisture endpoint |
| `ORACLE_APEX_POLL_INTERVAL` | `3` | How often to poll APEX (seconds) |
| `GEMINI_API_KEY` | `your_gemini_api_key_here` | Google Gemini API key (optional) |
| `FLASK_ENV` | `production` | Flask environment |

**Note:** Replace the APEX URLs with your actual Oracle APEX endpoints.

### 4️⃣ Deploy!

1. Click **"Create Web Service"**
2. Render will automatically:
   - Clone your repository
   - Install dependencies
   - Start your Flask app
   - Assign a URL like: `https://ecoview-backend.onrender.com`

### 5️⃣ Verify Deployment

Once deployed, test these endpoints:

```bash
# Health check
curl https://your-app-name.onrender.com/api/health

# Sensor data
curl https://your-app-name.onrender.com/api/sensor-data

# Thresholds
curl https://your-app-name.onrender.com/api/thresholds

# Alerts
curl https://your-app-name.onrender.com/api/alerts
```

You should see JSON responses from each endpoint.

## 🔄 Update Your Flutter App

Once deployed, update your Flutter app to use the Render URL:

**File:** `flutter_frontend/lib/services/api_service.dart`

```dart
class ApiService {
  // Replace with your Render URL
  static const String baseUrl = 'https://your-app-name.onrender.com/api';
  
  // ... rest of the code
}
```

Or add it as an environment variable in Flutter.

## 📊 Monitoring & Logs

### View Logs
- Go to your service in Render Dashboard
- Click **"Logs"** tab to see real-time logs
- You should see:
  ```
  ✅ Continuous APEX poller started
  🔍 Polling APEX...
  ✅ APEX poll successful! Got X readings.
  ```

### Health Check
- Render automatically monitors `/api/health`
- If it fails, Render will restart your service

## ⚙️ Configuration Options

### Increase Performance (Paid Plans)

If you upgrade to a paid plan, you can increase workers:

**In Render Dashboard → Settings → Start Command:**
```bash
gunicorn app:app --bind 0.0.0.0:$PORT --workers 4 --threads 8 --timeout 120
```

### Enable Auto-Deploy

In Render Dashboard:
1. Go to **Settings** → **Build & Deploy**
2. Enable **"Auto-Deploy"**
3. Now every push to `main` branch will auto-deploy

## 🐛 Troubleshooting

### Issue: "Application failed to respond"
**Solution:** Check logs for errors. Common causes:
- Missing environment variables (ORACLE_APEX_URL)
- Invalid APEX endpoints
- Port binding issues (use `$PORT` environment variable)

### Issue: "Module not found"
**Solution:** Make sure `requirements.txt` includes all dependencies:
```bash
flask==3.0.0
flask-cors==5.0.0
gunicorn==21.2.0
python-dotenv==1.0.1
requests==2.31.0
reportlab==3.6.12
google-generativeai==0.3.2
```

### Issue: APEX data not loading
**Solution:** 
1. Check environment variables are set correctly
2. Verify APEX URLs are accessible
3. Check logs for APEX polling errors

### Issue: 503 Service Unavailable
**Solution:** 
- Free tier apps sleep after 15 minutes of inactivity
- First request after sleep takes ~30 seconds to wake up
- Upgrade to paid plan for 24/7 uptime

## 📦 Alternative: Deploy Using render.yaml

You can also use the `render.yaml` file for infrastructure-as-code:

1. Push the `render.yaml` to your repository
2. In Render Dashboard, click **"New +"** → **"Blueprint"**
3. Connect your repository
4. Render will automatically detect `render.yaml` and configure everything

## 🎯 Production Checklist

Before going live:

- [ ] Set `FLASK_ENV=production`
- [ ] Add your real `GEMINI_API_KEY`
- [ ] Configure correct `ORACLE_APEX_URL`
- [ ] Test all API endpoints
- [ ] Update Flutter app with production URL
- [ ] Enable auto-deploy from GitHub
- [ ] Set up health check monitoring
- [ ] Consider upgrading to paid plan for better performance

## 🔗 Useful Links

- [Render Python Documentation](https://render.com/docs/deploy-flask)
- [Render Environment Variables](https://render.com/docs/environment-variables)
- [Render Free Tier Limits](https://render.com/docs/free)

## 📞 Support

If you encounter issues:
1. Check Render logs first
2. Verify environment variables are set
3. Test APEX endpoints manually
4. Check GitHub Actions (if configured)

---

## 🎉 Your Backend URL

After deployment, your backend will be available at:

```
https://your-app-name.onrender.com
```

All API endpoints will be under:
```
https://your-app-name.onrender.com/api/*
```

**Example Endpoints:**
- Health: `https://your-app-name.onrender.com/api/health`
- Sensor Data: `https://your-app-name.onrender.com/api/sensor-data`
- Alerts: `https://your-app-name.onrender.com/api/alerts`
- Thresholds: `https://your-app-name.onrender.com/api/thresholds`
- AI Analysis: `https://your-app-name.onrender.com/api/sensor-analysis/<sensor_type>`

---

**Happy Deploying! 🚀**
