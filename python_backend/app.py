from flask import Flask, jsonify, request, send_file
from flask_cors import CORS
import random
import time
import math
import os
import socket
import threading
import logging
from datetime import datetime
from dotenv import load_dotenv
import json
# Import the Gemini service
from gemini_service import get_gemini_analysis, get_gemini_recommendations
import requests
import http.client
from urllib.parse import urlparse
import concurrent.futures
import traceback
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, Image
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
import io

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Thread pool for async Gemini requests (non-blocking AI)
_gemini_executor = concurrent.futures.ThreadPoolExecutor(max_workers=3, thread_name_prefix='gemini')

# HTTP connection pool for faster APEX requests
_apex_connection_pool = {}
_apex_connection_lock = threading.Lock()

# Load environment variables from .env file
load_dotenv()

# ============================================================================
# THRESHOLD MANAGEMENT - Persistent storage for editable thresholds
# ============================================================================

THRESHOLDS_FILE = os.path.join(os.path.dirname(__file__), 'thresholds.json')

DEFAULT_THRESHOLDS = {
    "temperature": {
        "optimal": {"min": 20, "max": 27},
        "acceptable": {"min": 18, "max": 30}
    },
    "humidity": {
        "optimal": {"min": 45, "max": 70},
        "acceptable": {"min": 40, "max": 80}
    },
    "mq135": {"good": 200, "poor": 500},
    "mq2": {"safe": 300, "high": 750},
    "mq7": {"safe": 300, "high": 750},
    "soil_moisture": {
        "optimal": {"min": 40, "max": 60},
        "acceptable": {"min": 30, "max": 70}
    },
    "light": {"min": 0, "max": 4095}
}

def load_thresholds():
    """Load thresholds from JSON file, merge with defaults"""
    try:
        if os.path.exists(THRESHOLDS_FILE):
            with open(THRESHOLDS_FILE, 'r', encoding='utf-8') as f:
                data = json.load(f)
            # Merge with defaults to ensure all keys exist
            merged = DEFAULT_THRESHOLDS.copy()
            for key in data:
                if key in merged and isinstance(merged[key], dict):
                    merged[key].update(data[key])
                else:
                    merged[key] = data[key]
            return merged
    except Exception as e:
        logger.warning(f"Failed to load thresholds file: {e}")
    return DEFAULT_THRESHOLDS.copy()

def save_thresholds(thresholds_data):
    """Save thresholds to JSON file"""
    try:
        with open(THRESHOLDS_FILE, 'w', encoding='utf-8') as f:
            json.dump(thresholds_data, f, indent=2)
        return True
    except Exception as e:
        logger.error(f"Failed to save thresholds: {e}")
        return False

# Helper functions to determine sensor status
def _get_status_with_color(status_text):
    """
    Map status text to color hex codes for frontend consistency
    Returns tuple: (status_text, color_hex, severity_level)
    """
    status_lower = status_text.lower()
    
    # Green statuses (optimal/good)
    if any(word in status_lower for word in ['optimal', 'good', 'normal', 'bright', 'safe']):
        return (status_text, '#4CAF50', 'optimal')
    
    # Orange statuses (acceptable/moderate/warning)
    elif any(word in status_lower for word in ['acceptable', 'moderate', 'elevated', 'dim indoor', 'low light']):
        return (status_text, '#FF9800', 'warning')
    
    # Red statuses (critical/poor/high/danger)
    # Note: "dark night" is neutral for light readings, not critical
    elif any(word in status_lower for word in ['critical', 'poor', 'high', 'danger']) and 'dark night' not in status_lower:
        return (status_text, '#F44336', 'critical')
    
    # Gray statuses (neutral/informational like "dark night" for light sensors)
    elif any(word in status_lower for word in ['dark night', 'unknown', 'n/a']):
        return (status_text, '#9E9E9E', 'unknown')
    
    # Default (unknown)
    else:
        return (status_text, '#9E9E9E', 'unknown')

def _get_temperature_status(value):
    """Get status description for temperature reading
    Greenhouse optimal: 20-27°C (most vegetables and plants)
    """
    if 20 <= value <= 27:
        return "Optimal"
    elif (18 <= value < 20) or (27 < value <= 30):
        return "Acceptable"
    else:
        return "Critical"

def _get_humidity_status(value):
    """Get status description for humidity reading
    Greenhouse optimal: 45-70% (prevents disease while supporting growth)
    """
    if 45 <= value <= 70:
        return "Optimal"
    elif (71 <= value <= 80):
        return "Acceptable"
    else:
        return "Critical"

def _get_co2_status(value):
    """Get status description for CO2 reading"""
    if 300 <= value <= 800:
        return "Good"
    elif 800 < value <= 1500:
        return "Acceptable"
    else:
        return "High"

def _get_combined_air_quality_status(mq135_ppm, co2_ppm):
    """
    Get unified air quality status combining MQ135 sensor and CO2 levels.
    
    MQ135 thresholds (air quality sensor):
    - Good: ≤200 ppm
    - Moderate: 200-500 ppm
    - Poor: >500 ppm
    
    CO2 thresholds:
    - Good: 300-800 ppm
    - Acceptable: 800-1500 ppm
    - High: >1500 ppm
    
    Combined status considers BOTH readings:
    - Optimal: MQ135 ≤200 AND CO2 300-800
    - Good: MQ135 ≤200 OR CO2 ≤800
    - Moderate: MQ135 200-500 OR CO2 800-1500
    - High: MQ135 >500 OR CO2 >1500
    - Critical: Both sensors show poor readings
    """
    # Determine MQ135 status
    if mq135_ppm <= 200:
        mq135_status = "good"
    elif mq135_ppm <= 500:
        mq135_status = "moderate"
    else:
        mq135_status = "poor"
    
    # Determine CO2 status
    if 300 <= co2_ppm <= 800:
        co2_status = "good"
    elif co2_ppm <= 1500:
        co2_status = "moderate"
    else:
        co2_status = "poor"
    
    # Combined logic - worst reading takes precedence
    if mq135_status == "poor" and co2_status == "poor":
        return "Critical"
    elif mq135_status == "poor" or co2_status == "poor":
        return "High"
    elif mq135_status == "moderate" or co2_status == "moderate":
        return "Moderate"
    elif mq135_status == "good" and co2_status == "good":
        return "Optimal"
    else:
        return "Good"

def _get_light_status(value):
    """Get status description for light reading
    Thresholds based on ambient light intensity (0-4095 raw):
    • 0-300 = Dark Night (no light / remote areas)
    • 301-819 = Low Light (parks, moonlight, dim streets)
    • 820-1638 = Dim Indoor / Early Dusk
    • 1639-2457 = Moderate (cloudy day or shaded area)
    • 2458+ = Bright (good daylight)
    """
    if value <= 300:
        return "Dark Night"
    elif value <= 819:
        return "Low Light"
    elif value <= 1638:
        return "Dim Indoor"
    elif value <= 2457:
        return "Moderate"
    else:
        return "Bright"

def _get_soil_moisture_status(value, thresholds=None):
    """Get status description for soil moisture reading
    Uses configurable thresholds from thresholds.json
    Default thresholds:
    - 30-70%: Acceptable range
    - 40-60%: Optimal range
    """
    if thresholds is None:
        thresholds = load_thresholds()
    
    soil_config = thresholds.get('soil_moisture', {})
    opt_min = soil_config.get('optimal', {}).get('min', 40)
    opt_max = soil_config.get('optimal', {}).get('max', 60)
    acc_min = soil_config.get('acceptable', {}).get('min', 30)
    acc_max = soil_config.get('acceptable', {}).get('max', 70)
    
    if value < 15:
        return "Critical (Low)"
    elif value < acc_min:
        return "Low"
    elif value < opt_min:
        return "Acceptable"
    elif value <= opt_max:
        return "Optimal"
    elif value <= acc_max:
        return "Acceptable"
    elif value < 90:
        return "High"
    else:
        return "Critical (High)"
        
def ip_broadcast_service():
    """Broadcasts the server IP address on the local network"""
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    
    # Get the server's IP address
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # Doesn't actually connect but gets the route
        s.connect(('8.8.8.8', 1))
        ip_address = s.getsockname()[0]
    except Exception:
        hostname = socket.gethostname()
        ip_address = socket.gethostbyname(hostname)
    finally:
        s.close()
    
    print(f"Broadcasting server availability at {ip_address}:5000")
    
    # Broadcast message
    message = f"GREENHOUSE_SERVER:{ip_address}:5000".encode()
    
    while True:
        try:
            # Broadcast to the network
            server_socket.sendto(message, ('<broadcast>', 45678))
            time.sleep(5)  # Broadcast every 5 seconds
        except Exception as e:
            print(f"Broadcast error: {e}")
            time.sleep(10)  # Wait and retry

app = Flask(__name__)
# Enable CORS for all routes with explicit configuration for Chrome/web support
CORS(app, resources={
    r"/api/*": {
        "origins": "*",
        "methods": ["GET", "POST", "OPTIONS"],
        "allow_headers": ["Content-Type"]
    }
})

# ============================================================================
# THRESHOLD API ENDPOINTS - Allow frontend to read/write thresholds
# ============================================================================

@app.route('/api/thresholds', methods=['GET'])
def get_thresholds():
    """Get current thresholds configuration"""
    thresholds = load_thresholds()
    return jsonify({"thresholds": thresholds}), 200

@app.route('/api/thresholds', methods=['POST'])
def set_thresholds():
    """Update thresholds configuration"""
    try:
        payload = request.get_json(force=True)
        if not isinstance(payload, dict):
            return jsonify({"error": "Invalid payload - must be a dictionary"}), 400
        
        # Save the new thresholds
        success = save_thresholds(payload)
        if not success:
            return jsonify({"error": "Failed to save thresholds"}), 500
        
        return jsonify({"message": "Thresholds updated successfully", "thresholds": payload}), 200
    except Exception as e:
        logger.error(f"Error updating thresholds: {e}")
        return jsonify({"error": str(e)}), 500

# NOTE: To make this server accessible from tablet or other devices on your network:
# 1. Make sure the Flask server is running with host='0.0.0.0' 
#    (this is already set in the code below when the app is run)
# 2. Find your computer's IP address:
#    - On Windows: Open command prompt and type 'ipconfig'
#    - On Mac/Linux: Open terminal and type 'ifconfig' or 'ip addr'
# 3. Use this IP address in the tablet app's settings

# Sample data - replace with your actual data model/database
items = [
    {"id": 1, "name": "Item 1", "description": "Description for item 1"},
    {"id": 2, "name": "Item 2", "description": "Description for item 2"}
]

# ============================================================================
# APEX DATA SOURCE - All sensor data comes from Oracle APEX (NO SIMULATED DATA)
# ============================================================================

# PRIMARY endpoint for greenhouse gas sensors (MQ135, MQ2, MQ7, BMP280, DHT22, flame, light)
ORACLE_APEX_URL = os.getenv('ORACLE_APEX_URL', "https://oracleapex.com/ords/g3_data/iot/greenhouse/")

# SECONDARY endpoint for soil/plant metrics (moisture, temperature, ec, ph, NPK)
ORACLE_APEX_SOIL_URL = os.getenv('ORACLE_APEX_SOIL_URL', "https://oracleapex.com/ords/g3_data/groups/data/10")

def get_apex_connection(url):
    """Get or create persistent HTTPS connection to APEX for connection pooling"""
    parsed = urlparse(url)
    host = parsed.hostname
    
    with _apex_connection_lock:
        if host not in _apex_connection_pool:
            logger.info(f"Creating new APEX connection pool for {host}")
            _apex_connection_pool[host] = http.client.HTTPSConnection(
                host, 
                timeout=5,  # Shorter timeout with persistent connection
                blocksize=8192  # Larger buffer for faster reads
            )
        return _apex_connection_pool[host]

def fetch_apex_readings(apex_url=None, timeout=10):
    """Fetch list of readings from Oracle APEX using http.client (more reliable than requests).
       Returns a list of dict readings or empty list on failure.
       NOW WITH CONNECTION POOLING for 2-3x faster requests!
    """
    import http.client
    import json
    from urllib.parse import urlparse
    
    url = apex_url or ORACLE_APEX_URL
    try:
        # Parse the URL
        parsed = urlparse(url)
        host = parsed.hostname  # e.g., "oracleapex.com"
        path = parsed.path or "/"  # e.g., "/ords/g3_data/iot/greenhouse/"
        
        # Get connection from pool (reuses existing connection!)
        try:
            conn = get_apex_connection(url)
            
            # Make request with keep-alive header for connection reuse
            conn.request("GET", path, headers={
                'Connection': 'keep-alive',
                'Accept-Encoding': 'gzip, deflate'  # Request compression
            })
            
            # Get response
            res = conn.getresponse()
        except Exception as conn_err:
            # Connection died, remove from pool and retry
            logger.warning(f"Connection pool error: {conn_err}, creating fresh connection")
            with _apex_connection_lock:
                if host in _apex_connection_pool:
                    try:
                        _apex_connection_pool[host].close()
                    except:
                        pass
                    del _apex_connection_pool[host]
            
            # Retry with fresh connection
            conn = http.client.HTTPSConnection(host, timeout=timeout)
            conn.request("GET", path)
            res = conn.getresponse()
        
        if res.status == 200:
            # Read response - handle GZIP compression!
            data_bytes = res.read()
            
            # Check if response is gzip-compressed (starts with 0x1f 0x8b)
            import gzip
            if len(data_bytes) >= 2 and data_bytes[0] == 0x1f and data_bytes[1] == 0x8b:
                try:
                    data_bytes = gzip.decompress(data_bytes)
                except Exception as e:
                    print(f"GZIP decompression failed: {e}")
                    return []
            
            # Decode JSON
            data = json.loads(data_bytes.decode("utf-8"))
            
            # normalize possible shapes: {"items": [...]} or [...]
            if isinstance(data, dict) and "items" in data and isinstance(data["items"], list):
                items = data["items"]
            elif isinstance(data, list):
                items = data
            elif isinstance(data, dict):
                # single-object payload -> wrap
                items = [data]
            else:
                return []
            
            # Ensure each item has a numeric timestamp for sorting
            # Use APEX timestamp but fix the year to 2025
            import time
            from datetime import datetime
            
            normalized = []
            for idx, it in enumerate(items):
                it_copy = dict(it)

                # Get the original APEX timestamp. Different APEX endpoints use different keys:
                # - ISO style: "timestamp_reading" -> "2025-10-29T15:21:22.971802Z"
                # - groups endpoint: "corrected_created_at" -> "30-OCT-2025 15:02:22"
                # We'll try several common keys and parsing strategies.
                apex_ts_str = it.get("timestamp_reading", "")
                if not apex_ts_str:
                    # try other common fields returned by APEX groups endpoints
                    apex_ts_str = it.get("corrected_created_at", "") or it.get("created_at", "") or it.get("ts", "") or it.get("time", "")

                if apex_ts_str:
                    # Normalize whitespace/newlines produced by some HTML/JSON renderings
                    apex_ts_str_clean = " ".join(str(apex_ts_str).split())
                    parsed_ok = False
                    # Try ISO format with microseconds / Z
                    try:
                        apex_dt = datetime.strptime(apex_ts_str_clean.replace('Z', ''), "%Y-%m-%dT%H:%M:%S.%f")
                        it_copy["timestamp"] = apex_dt.timestamp()
                        parsed_ok = True
                    except Exception:
                        pass

                    if not parsed_ok:
                        # Try ISO without microseconds
                        try:
                            apex_dt = datetime.strptime(apex_ts_str_clean.replace('Z', ''), "%Y-%m-%dT%H:%M:%S")
                            it_copy["timestamp"] = apex_dt.timestamp()
                            parsed_ok = True
                        except Exception:
                            pass

                    if not parsed_ok:
                        # Try APEX human-readable like '30-OCT-2025 15:02:22' or '30-OCT-2025\n15:02:22'
                        try:
                            # Ensure month abbreviation is upper-case (e.g., OCT)
                            apex_norm = apex_ts_str_clean.upper()
                            # Remove any commas
                            apex_norm = apex_norm.replace(',', '')
                            apex_dt = datetime.strptime(apex_norm, "%d-%b-%Y %H:%M:%S")
                            it_copy["timestamp"] = apex_dt.timestamp()
                            parsed_ok = True
                        except Exception:
                            pass

                    if not parsed_ok:
                        # Last resort: try to extract any integer-like epoch in the string
                        try:
                            import re
                            m = re.search(r"(1[0-9]{9}|2[0-9]{9})", apex_ts_str_clean)
                            if m:
                                it_copy["timestamp"] = float(m.group(0))
                                parsed_ok = True
                        except Exception:
                            pass

                    if not parsed_ok:
                        print(f"Failed to parse timestamp '{apex_ts_str}'; using pull-time fallback")
                        it_copy["timestamp"] = time.time() - (idx * 10)
                else:
                    # No timestamp in APEX data, use current time
                    it_copy["timestamp"] = time.time() - (idx * 10)
                
                it_copy["_ts_num"] = it_copy["timestamp"]
                it_copy["_pull_time"] = time.time()  # Track when we pulled this data
                normalized.append(it_copy)
            # sort descending by timestamp numeric (newest first)
            normalized.sort(key=lambda x: x.get("_ts_num", 0), reverse=True)
            
            # Log the timestamps of the first 3 readings to verify we're getting fresh data
            if len(normalized) >= 3:
                latest_ts = datetime.fromtimestamp(normalized[0].get("timestamp", 0)).strftime("%Y-%m-%d %H:%M:%S")
                second_ts = datetime.fromtimestamp(normalized[1].get("timestamp", 0)).strftime("%Y-%m-%d %H:%M:%S")
                third_ts = datetime.fromtimestamp(normalized[2].get("timestamp", 0)).strftime("%Y-%m-%d %H:%M:%S")
                temp1 = normalized[0].get("temperature_bmp280", "N/A")
                temp2 = normalized[1].get("temperature_bmp280", "N/A")
                print(f"📊 Latest APEX Data: {latest_ts} (Temp: {temp1}°C), 2nd: {second_ts} (Temp: {temp2}°C), 3rd: {third_ts}")
            
            # DON'T close connection - keep it in pool for reuse!
            return normalized
        else:
            print(f"fetch_apex_readings: HTTP {res.status}")
            # DON'T close connection - keep it in pool!
            return []
            
    except Exception as e:
        print(f"fetch_apex_readings error: {e}")
        # If connection error, remove from pool
        try:
            parsed = urlparse(apex_url or ORACLE_APEX_URL)
            with _apex_connection_lock:
                if parsed.hostname in _apex_connection_pool:
                    try:
                        _apex_connection_pool[parsed.hostname].close()
                    except:
                        pass
                    del _apex_connection_pool[parsed.hostname]
        except:
            pass
        return []

def build_derived_from_reading(r):
    """Build derived fields from a single reading dict r from APEX.
       NO CONVERSIONS - use APEX data exactly as provided.
    """
    # helper to get numeric safely
    def num(key, default=0.0):
        try:
            return float(r.get(key, default))
        except Exception:
            return default

    temp_b = num("temperature_bmp280", None)
    temp_d = num("temperature_dht22", None)
    # prefer average if both present
    if temp_b is not None and temp_d is not None:
        temperature = round((temp_b + temp_d) / 2.0, 1)
    elif temp_b is not None:
        temperature = round(temp_b, 1)
    elif temp_d is not None:
        temperature = round(temp_d, 1)
    else:
        temperature = None

    # USE APEX VALUES DIRECTLY - NO CONVERSIONS!
    # APEX already sends mq135_drop, mq2_drop, mq7_drop calculated
    # If negative, use 0 (sensor calibration issue)
    mq135_drop = max(0, round(num("mq135_drop", 0), 1))  # Direct from APEX (PPM), never negative
    mq2_drop = max(0, round(num("mq2_drop", 0), 1))      # Direct from APEX (PPM), never negative
    mq7_drop = max(0, round(num("mq7_drop", 0), 1))      # Direct from APEX (PPM), never negative
    
    mq135_baseline = round(num("mq135_baseline", 0), 1)  # Direct from APEX
    mq2_baseline = round(num("mq2_baseline", 0), 1)      # Direct from APEX
    mq7_baseline = round(num("mq7_baseline", 0), 1)      # Direct from APEX

    # Light intensity - use RAW value directly (0-4095)
    light_raw = num("light_raw", None)
    if light_raw is not None:
        light_intensity = round(light_raw, 0)
    else:
        # Fallback to light_percent if available
        light_percent = num("light_percent", None)
        if light_percent is not None:
            # Convert percentage back to raw (0-4095 range)
            light_intensity = round((light_percent / 100.0) * 4095, 0)
        else:
            light_intensity = 0

    flame_raw = num("flame_raw", 4095)
    
    # Use flame_detected from APEX payload directly
    # APEX sends: 1 = detected, 0 = not detected
    flame_detected_value = r.get("flame_detected", 0)
    if isinstance(flame_detected_value, (int, float)):
        flame_detected = bool(flame_detected_value)
    elif isinstance(flame_detected_value, bool):
        flame_detected = flame_detected_value
    elif isinstance(flame_detected_value, str):
        flame_detected = flame_detected_value.strip().lower() in ("yes", "y", "true", "1")
    else:
        flame_detected = bool(flame_raw < 2000)
    
    flame_status = "Flame Detected" if flame_detected else "Flame Not Detected"

    co2_level = round(400 + mq135_drop * 1.2, 1)

    # Prefer sloi_moisture from APEX when present (some APEX endpoints use that key).
    sloi_raw = None
    # Many APEX endpoints use key 'moisture' for soil moisture; check that too.
    for _k in ('sloi_moisture', 'moisture', 'sloi', 'sloiMoisture'):
        if _k in r and r.get(_k) is not None:
            try:
                sloi_raw = float(r.get(_k))
                break
            except Exception:
                sloi_raw = None

    sloi_moisture = round(sloi_raw) if sloi_raw is not None else None
    # Final soil_moisture uses sloi_moisture when available, otherwise fall back to existing key
    soil_moisture_value = round(sloi_raw) if sloi_raw is not None else round(num("soil_moisture", 45))

    # Get status strings for key sensors
    humidity_val = round(num("humidity", 0.0), 1)
    temp_status = _get_temperature_status(temperature) if temperature is not None else "Unknown"
    humidity_status = _get_humidity_status(humidity_val)
    soil_status = _get_soil_moisture_status(soil_moisture_value)
    light_status = _get_light_status(light_intensity)
    air_quality_status = _get_combined_air_quality_status(mq135_drop, co2_level)
    
    # Get color coding for each status
    temp_status_text, temp_color, temp_severity = _get_status_with_color(temp_status)
    humidity_status_text, humidity_color, humidity_severity = _get_status_with_color(humidity_status)
    soil_status_text, soil_color, soil_severity = _get_status_with_color(soil_status)
    light_status_text, light_color, light_severity = _get_status_with_color(light_status)
    air_status_text, air_color, air_severity = _get_status_with_color(air_quality_status)

    derived = {
        "temperature": temperature,
        "temperature_status": temp_status_text,
        "temperature_color": temp_color,
        "temperature_severity": temp_severity,
        "humidity": round(num("humidity", 0.0), 1),
        "humidity_status": humidity_status_text,
        "humidity_color": humidity_color,
        "humidity_severity": humidity_severity,
        "co2_level": co2_level,
        "light": light_intensity,  # Raw light intensity (0-4095)
        "light_raw": light_intensity,  # Also include as light_raw for compatibility
        "light_status": light_status_text,
        "light_color": light_color,
        "light_severity": light_severity,
        "pressure": round(num("pressure", 0.0), 1),
        "altitude": round(num("altitude", 0.0), 1),
    # Include both fields: prefer sloi_moisture for consumers that request it
    "sloi_moisture": sloi_moisture,
    "soil_moisture": soil_moisture_value,
        "soil_moisture_status": soil_status_text,
        "soil_moisture_color": soil_color,
        "soil_moisture_severity": soil_severity,
        "flame_detected": flame_detected,
        "flame_status": flame_status,
        # Gas sensor values - DIRECT FROM APEX (already in PPM)
        "mq135_drop": mq135_drop,
        "mq2_drop": mq2_drop,
        "mq7_drop": mq7_drop,
        "mq135_baseline": mq135_baseline,
        "mq2_baseline": mq2_baseline,
        "mq7_baseline": mq7_baseline,
        # Status based on REAL thresholds from system specification
        # COMBINED Air Quality Status (MQ135 + CO2)
        "air_quality": air_status_text,
        "air_quality_color": air_color,
        "air_quality_severity": air_severity,
        # Individual sensor statuses (for reference/debugging)
        "mq135_status": "Good" if mq135_drop <= 200 else ("Poor" if mq135_drop > 500 else "Moderate"),
        "co2_status": _get_co2_status(co2_level),
        # MQ2: >750 = high, >300 = elevated, ≤300 = safe
        "flammable_gas": "Safe" if mq2_drop <= 300 else ("High" if mq2_drop > 750 else "Elevated"),
        "smoke_level": "Safe" if mq2_drop <= 300 else ("High" if mq2_drop > 750 else "Elevated"),  # Alias for Flutter
        # MQ7: >750 = high, >300 = elevated, ≤300 = safe
        "co_level": "Safe" if mq7_drop <= 300 else ("High" if mq7_drop > 750 else "Elevated"),
        "timestamp": r.get("timestamp", r.get("_ts_num", time.time())),
        "co2_air_quality": {
            "co2": co2_level,
            "air_quality": "Good" if mq135_drop <= 200 else ("Poor" if mq135_drop > 500 else "Moderate"),
        },
        "pressure_altitude": {
            "pressure": round(num("pressure", 0.0), 1),
            "altitude": round(num("altitude", 0.0), 1)
        }
    }
    return derived

# In-memory cache for APEX readings (newest-first)
apex_cache = []
apex_cache_lock = threading.Lock()

# Poll interval (seconds) for fetching APEX data; configurable via env
ORACLE_APEX_POLL_INTERVAL = float(os.getenv('ORACLE_APEX_POLL_INTERVAL', '2'))

def apex_poller():
    """Background thread: poll APEX endpoint and keep cached latest readings."""
    global apex_cache
    url = ORACLE_APEX_URL
    interval = ORACLE_APEX_POLL_INTERVAL
    print(f"Starting APEX poller (url={url}, interval={interval}s)")
    while True:
        try:
            readings = fetch_apex_readings(url, timeout=5)
            if readings:
                with apex_cache_lock:
                    apex_cache = readings
            time.sleep(interval)
        except Exception as e:
            print(f"APEX poller error: {e}")
            time.sleep(max(1, interval))

# Smart cache with TTL for APEX data - continuously updated by background poller
_smart_cache = {
    'data': None,
    'timestamp': None,
    'ttl_seconds': 3,  # 3-second cache TTL based on APEX response time
    'fetch_interval': 3  # Poll APEX every 3 seconds
}
_smart_cache_lock = threading.Lock()

def continuous_apex_poller():
    """
    Background thread that continuously polls PRIMARY APEX endpoint (greenhouse sensors).
    Additionally fetches soil moisture from SECONDARY endpoint and merges ONLY moisture+timestamp.
    """
    global _smart_cache
    interval = _smart_cache.get('fetch_interval', 3)
    print(f"🔄 Starting continuous APEX poller (fetching every {interval} seconds)...")
    print(f"   Primary (all sensors): {ORACLE_APEX_URL}")
    print(f"   Secondary (soil moisture only): {ORACLE_APEX_SOIL_URL}")
    
    while True:
        try:
            print(f"🔍 Polling APEX...")
            
            # PRIMARY fetch: greenhouse sensors (this is the main data source)
            readings = fetch_apex_readings(ORACLE_APEX_URL, timeout=60)
            
            # SECONDARY fetch: soil moisture only (supplement main data)
            soil_readings = None
            try:
                soil_readings = fetch_apex_readings(ORACLE_APEX_SOIL_URL, timeout=60)
            except Exception as e:
                print(f"⚠️ Soil endpoint poll failed (non-critical): {e}")
            
            if readings:
                # If we have soil data, merge ONLY moisture into the latest greenhouse reading
                if soil_readings and len(soil_readings) > 0:
                    latest_soil = soil_readings[0]
                    # Add soil moisture to the latest reading
                    if 'moisture' in latest_soil and latest_soil['moisture'] is not None:
                        readings[0]['moisture'] = latest_soil['moisture']
                        readings[0]['sloi_moisture'] = latest_soil['moisture']  # Also set alias
                        print(f"   ✅ Added soil moisture: {latest_soil['moisture']}%")
                
                with _smart_cache_lock:
                    _smart_cache['data'] = readings
                    _smart_cache['timestamp'] = datetime.now()
                print(f"✅ APEX poll successful! Got {len(readings)} readings. Cache updated.")
            else:
                print(f"⚠️ APEX poll returned no data. Keeping existing cache.")
                
        except Exception as e:
            print(f"❌ APEX poll error: {e}")
        
        # Wait for the next poll interval
        time.sleep(interval)

def get_cached_apex_or_fetch():
    """
    Smart caching function that returns data from continuously-updated cache
    (cache is kept fresh by background poller every 3 seconds)
    """
    with _smart_cache_lock:
        # Return cached data if available
        if _smart_cache['data'] is not None and _smart_cache['timestamp'] is not None:
            age = (datetime.now() - _smart_cache['timestamp']).total_seconds()
            if age < 10:  # Cache is reasonably fresh (within 10 seconds)
                return _smart_cache['data'], f'cache_age_{age:.0f}s'
            else:
                return _smart_cache['data'], f'cache_stale_{age:.0f}s'
        
        # No cache available yet (poller hasn't succeeded yet)
        print("⏳ Waiting for background poller to fetch first APEX data...")
        return None, 'no_data'

# ...existing code...

@app.route('/api/items', methods=['GET'])
def get_items():
    return jsonify(items)

@app.route('/api/items/<int:item_id>', methods=['GET'])
def get_item(item_id):
    item = next((item for item in items if item['id'] == item_id), None)
    if item:
        return jsonify(item)
    return jsonify({"error": "Item not found"}), 404

@app.route('/api/items', methods=['POST'])
def add_item():
    new_item = request.json
    # In a real app, validate input and generate proper ID
    if 'id' not in new_item:
        new_item['id'] = len(items) + 1
    items.append(new_item)
    return jsonify(new_item), 201

@app.route('/api/sensor-data', methods=['GET'])
def get_sensor_data():
    # ONLY USE APEX DATA - NO SIMULATION
    readings, cache_status = get_cached_apex_or_fetch()
    if readings:
        latest = readings[0]
        derived = build_derived_from_reading(latest)
        merged = {**{k: v for k, v in latest.items() if not k.startswith("_")}, **derived}
        merged['_cache_status'] = cache_status
        merged['_data_source'] = 'apex'
        return jsonify(merged)
    else:
        # No APEX data available yet - return error
        return jsonify({
            "error": "APEX data not available yet",
            "message": "Waiting for APEX to respond. Please wait...",
            "_data_source": "none"
        }), 503

@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy", "message": "Flask API is running"})

@app.route('/api/sensor-analysis/<sensor_type>', methods=['GET'])
def get_sensor_analysis(sensor_type):
    """
    Get detailed analysis for a specific sensor - ONLY FROM APEX
    Supports ?include_ai=false to skip AI analysis for INSTANT page load!
    """
    time_range = request.args.get('time_range', 'hours')
    include_ai = request.args.get('include_ai', 'true').lower() == 'true'
    
    # Determine number of points requested
    data_points = {
        'seconds': 60, 'minutes': 60, 'hours': 24,
        'days': 30, 'weeks': 52, 'months': 12, 'years': 5
    }
    num_points = data_points.get(time_range, 30)

    # Helper to extract numeric value for a sensor key from a reading
    def extract_value_for_sensor(reading, key):
        try:
            if key == 'temperature':
                # prefer averaged temperature if both sensors present
                a = reading.get('temperature')
                if a is not None:
                    return float(a)
                b1 = reading.get('temperature_bmp280')
                b2 = reading.get('temperature_dht22')
                if b1 is not None and b2 is not None:
                    return (float(b1) + float(b2)) / 2.0
                if b1 is not None:
                    return float(b1)
                if b2 is not None:
                    return float(b2)
                return None
            elif key == 'light':
                # Use raw light intensity value (0-4095)
                if 'light_raw' in reading and reading['light_raw'] is not None:
                    return float(reading['light_raw'])
                if 'light' in reading and reading['light'] is not None:
                    return float(reading['light'])
                # Fallback: convert light_percent to raw if available
                if 'light_percent' in reading and reading['light_percent'] is not None:
                    return float(reading['light_percent']) * 4095.0 / 100.0
                return None
            elif key == 'soil_moisture':
                # Check for various soil moisture field names from different APEX endpoints
                # Prefer sloi_moisture/moisture from groups endpoint, fallback to soil_moisture
                for field in ('sloi_moisture', 'moisture', 'soil_moisture'):
                    if field in reading and reading[field] is not None:
                        return float(reading[field])
                return None
            else:
                if key in reading:
                    return float(reading[key])
                # try derived keys
                if key + '_raw' in reading:
                    return float(reading[key + '_raw'])
        except Exception:
            return None
        return None

    # ONLY USE APEX DATA
    readings, cache_status = get_cached_apex_or_fetch()
    if readings:
        latest = readings[0]
        derived = build_derived_from_reading(latest)
        current_data = {**{k: v for k, v in latest.items() if not k.startswith("_")}, **derived}
        current_data['_data_source'] = 'apex'
        current_data['_cache_status'] = cache_status
        # Include ALL readings in historical data (including the latest at index 0)
        historical_raw = readings[0:num_points] if len(readings) > 0 else []
    else:
        # No APEX data available - return error
        return jsonify({
            "error": "APEX data not available yet",
            "message": "Waiting for APEX to respond...",
            "sensor_type": sensor_type
        }), 503

    # Map requested sensor_type to a field and unit and status function
    st = sensor_type.lower()
    if 'temp' in st:
        key = 'temperature'
        unit = '°C'
        status_fn = _get_temperature_status
    elif 'humid' in st:
        key = 'humidity'
        unit = '%'
        status_fn = _get_humidity_status
    elif 'co2' in st or 'co₂' in st or 'air quality' in st.lower() or 'mq135' in st or 'air_quality' in st:
        # Check if they want the drop value or the co2_level estimate
        if 'mq135' in st or 'air quality' in st.lower() or 'air_quality' in st:
            key = 'mq135_drop'  # Direct from APEX (already in PPM)
            unit = 'ppm'
            # MQ135 thresholds: >500 = poor, >200 = degraded, ≤200 = good
            status_fn = lambda v: "Good" if v <= 200 else ("Poor" if v > 500 else "Moderate")
        else:
            key = 'co2_level'
            unit = 'ppm'
            status_fn = _get_co2_status
    elif 'light' in st:
        key = 'light'  # Now using raw light intensity (0-4095)
        unit = 'lux'  # Display as lux
        status_fn = _get_light_status
    elif 'soil' in st:
        key = 'soil_moisture'
        unit = '%'
        status_fn = _get_soil_moisture_status
    elif 'flame' in st:
        key = 'flame_detected'  # Use boolean value for charting (True/False -> 1/0)
        unit = ''  # No unit for binary sensor
        status_fn = lambda v: "Flame Detected" if v else "Flame Not Detected"
    elif 'mq2' in st or 'smoke' in st or 'lpg' in st or 'flammable' in st.lower():
        key = 'mq2_drop'  # Direct from APEX (already in PPM)
        unit = 'ppm'
        # MQ2 thresholds: >750 = high, >300 = elevated, ≤300 = safe
        status_fn = lambda v: "Safe" if v <= 300 else ("High" if v > 750 else "Elevated")
    elif 'mq7' in st or ('co' in st and 'co2' not in st) or 'carbon monoxide' in st.lower():
        key = 'mq7_drop'  # Direct from APEX (already in PPM)
        unit = 'ppm'
        # MQ7 thresholds: >750 = high, >300 = elevated, ≤300 = safe
        status_fn = lambda v: "Safe" if v <= 300 else ("High" if v > 750 else "Elevated")
    elif 'pressure' in st and 'altitude' in st:
        # Wildcard: Pressure & Altitude - return both as combined analysis
        key = 'pressure'  # Primary key for value
        unit = 'hPa'
        status_fn = lambda v: "Normal" if 990 <= v <= 1030 else ("Low" if v < 990 else "High")
    elif 'pressure' in st:
        key = 'pressure'
        unit = 'hPa'
        status_fn = lambda v: "Normal" if 990 <= v <= 1030 else ("Low" if v < 990 else "High")
    elif 'altitude' in st:
        key = 'altitude'
        unit = 'm'
        # Altitude status: Low < 500m, Normal 500-1500m, High > 1500m
        status_fn = lambda v: "Low" if v < 500 else ("High" if v > 1500 else "Normal")
    else:
        # default fallback - try to match the sensor type directly as a key
        key = sensor_type.lower().replace(' ', '_')
        unit = ''
        status_fn = lambda v: "Unknown"
        # If the key doesn't exist, fall back to temperature
        if key not in ['temperature', 'humidity', 'light', 'soil_moisture', 'pressure', 'altitude', 
                       'co2_level', 'mq135_drop', 'mq2_drop', 'mq7_drop', 'flame_detected']:
            key = 'temperature'
            unit = '°C'
            status_fn = _get_temperature_status

    # Compute current value
    current_value = extract_value_for_sensor(current_data, key)
    if current_value is None and key in current_data:
        try:
            current_value = float(current_data.get(key))
        except Exception:
            current_value = 0.0

    # Determine status
    if status_fn and current_value is not None:
        try:
            status = status_fn(current_value)
        except Exception:
            status = 'Unknown'
    else:
        status = 'Unknown'

    # Build historical data series
    historical_data = []
    if historical_raw:
        # Use actual timestamps from when data was pulled
        for r in historical_raw:
            # Get the timestamp we added when pulling from APEX
            ts = r.get('timestamp', r.get('_ts_num', time.time()))
            
            val = extract_value_for_sensor(r, key)
            if val is None:
                # try reading key directly
                try:
                    val = float(r.get(key, 0.0))
                except Exception:
                    val = 0.0
            historical_data.append({"value": val, "timestamp": ts})
        
        # Sort by timestamp ASCENDING (oldest first) for proper chart display
        historical_data.sort(key=lambda x: x['timestamp'])

    # Ensure at least two points for charting
    if len(historical_data) < 2:
        # Create minimal dataset with current value
        now_ts = time.time()
        val = current_value if current_value is not None else 0.0
        historical_data = [
            {"value": val, "timestamp": now_ts - 10},
            {"value": val, "timestamp": now_ts}
        ]

    # Optionally get AI analysis (Gemini) - can be skipped for faster loading
    analysis_text = ''
    if include_ai:
        try:
            analysis_text = get_gemini_analysis(sensor_type, current_value or 0.0, unit, status, [d['value'] for d in historical_data])
        except Exception as e:
            logger.warning(f"AI analysis failed for {sensor_type}: {e}")
            analysis_text = ''

    response = {
        "sensor_type": sensor_type,
        "current_value": current_value,
        "unit": unit,
        "status": status,
        "historical_data": historical_data,
        "time_range": time_range,
        "analysis": analysis_text,
        "timestamp": current_data.get('timestamp', time.time()),
        "raw_data": current_data
    }

    return jsonify(response)
# ...existing code...

@app.route('/api/sensor-analysis/<sensor_type>/ai', methods=['GET'])
def get_sensor_ai_only(sensor_type):
    """
    Get ONLY AI analysis for a sensor - called separately for async loading!
    This endpoint is FAST because it skips historical data processing.
    """
    try:
        readings, _ = get_cached_apex_or_fetch()
        if not readings:
            return jsonify({'analysis': 'No data available'}), 503
        
        latest = readings[0]
        sensor_data = {**latest, **build_derived_from_reading(latest)}
        
        # Determine sensor specifics based on type
        st = sensor_type.lower()
        if 'temp' in st:
            current_value = sensor_data.get('temperature', 0)
            unit = '°C'
            status = _get_temperature_status(current_value)
        elif 'humid' in st:
            current_value = sensor_data.get('humidity', 0)
            unit = '%'
            status = _get_humidity_status(current_value)
        elif 'light' in st:
            current_value = sensor_data.get('light', 0)
            unit = 'lux'
            status = _get_light_status(current_value)
        elif 'co2' in st or 'air' in st or 'mq135' in st or 'air_quality' in st:
            current_value = sensor_data.get('mq135_drop', 0)
            unit = 'ppm'
            status = "Good" if current_value <= 200 else ("Poor" if current_value > 500 else "Moderate")
        elif 'mq2' in st or 'smoke' in st or 'flammable' in st:
            current_value = sensor_data.get('mq2_drop', 0)
            unit = 'ppm'
            status = "Safe" if current_value <= 300 else ("High" if current_value > 750 else "Elevated")
        elif 'mq7' in st or ('co' in st and 'co2' not in st) or 'carbon monoxide' in st:
            current_value = sensor_data.get('mq7_drop', 0)
            unit = 'ppm'
            status = "Safe" if current_value <= 300 else ("High" if current_value > 750 else "Elevated")
        elif 'soil' in st or 'moisture' in st:
            # Check for various soil moisture field names
            current_value = (sensor_data.get('sloi_moisture') or 
                           sensor_data.get('moisture') or 
                           sensor_data.get('soil_moisture') or 0)
            unit = '%'
            status = _get_soil_moisture_status(current_value)
        elif 'altitude' in st:
            current_value = sensor_data.get('altitude', 0)
            unit = 'm'
            status = "Low" if current_value < 500 else ("High" if current_value > 1500 else "Normal")
        elif 'pressure' in st:
            current_value = sensor_data.get('pressure', 0)
            unit = 'hPa'
            status = "Normal" if 990 <= current_value <= 1030 else ("Low" if current_value < 990 else "High")
        else:
            current_value = 0
            unit = ''
            status = 'Unknown'
        
        # Get last 10 readings for trend analysis
        historical_values = []
        for r in readings[:10]:
            if 'temp' in st:
                val = r.get('temperature', 0)
            elif 'humid' in st:
                val = r.get('humidity', 0)
            elif 'light' in st:
                val = r.get('light', 0)
            elif 'co2' in st or 'air' in st or 'mq135' in st or 'air_quality' in st:
                val = r.get('mq135_drop', 0)
            elif 'mq2' in st or 'smoke' in st or 'flammable' in st:
                val = r.get('mq2_drop', 0)
            elif 'mq7' in st or ('co' in st and 'co2' not in st) or 'carbon monoxide' in st:
                val = r.get('mq7_drop', 0)
            elif 'soil' in st or 'moisture' in st:
                # Check for various soil moisture field names from merged data
                val = (r.get('sloi_moisture') or 
                      r.get('moisture') or 
                      r.get('soil_moisture') or 0)
            elif 'altitude' in st:
                val = r.get('altitude', 0)
            elif 'pressure' in st:
                val = r.get('pressure', 0)
            else:
                val = 0
            historical_values.append(val)
        
        # Call Gemini AI
        analysis_text = get_gemini_analysis(sensor_type, current_value, unit, status, historical_values)
        
        return jsonify({
            'analysis': analysis_text,
            'timestamp': time.time(),
            'sensor_type': sensor_type
        }), 200
        
    except Exception as e:
        logger.error(f"AI analysis error for {sensor_type}: {e}")
        return jsonify({'analysis': f'AI analysis temporarily unavailable'}), 500

@app.route('/api/ai-recommendations', methods=['GET'])
def get_ai_recommendations():
    """
    Get AI-powered recommendations from Gemini based on APEX sensor data.
    """
    # ONLY USE APEX DATA
    readings, _ = get_cached_apex_or_fetch()
    if not readings:
        return jsonify({"error": "No APEX data available"}), 503
    
    latest = readings[0]
    current_data = {**latest, **build_derived_from_reading(latest)}
    
    # Use Gemini AI to generate recommendations based on APEX sensor data
    recommendations = get_gemini_recommendations(current_data)
    
    # Return recommendations along with timestamp
    return jsonify({
        "recommendations": recommendations,
        "timestamp": current_data.get('timestamp', time.time())
    })

@app.route('/api/alerts', methods=['GET'])
def get_alerts():
    """
    Get alerts when sensors are outside normal ranges - ONLY FROM APEX DATA
    Triggers sound notification in frontend when alerts exist.
    Uses editable thresholds from thresholds.json
    """
    # ONLY USE APEX DATA
    readings, _ = get_cached_apex_or_fetch()
    if not readings:
        return jsonify({"error": "No APEX data available", "alerts": [], "alert_count": 0, "should_alert": False}), 503
    
    latest = readings[0]
    current_data = {**latest, **build_derived_from_reading(latest)}
    
    # Load current thresholds (editable from frontend)
    thresholds = load_thresholds()
    
    # Generate alerts based on thresholds
    alerts = []
    
    # CRITICAL SAFETY ALERTS (highest priority)
    
    # Flame detection alert - check if flame_detected is truthy (boolean, 'Yes', 1, etc.)
    flame_detected = current_data.get('flame_detected')
    if flame_detected and str(flame_detected).lower() in ('true', 'yes', '1'):
        alerts.append({
            "title": "🔥 FIRE HAZARD",
            "message": "Flame or strong IR source detected. Inspect all heating equipment immediately!",
            "timestamp": current_data['timestamp'],
            "sensor_type": "flame",
            "severity": "critical",
            "value": current_data.get('flame_raw', 0),
            "unit": "raw",
            "sound": True  # Trigger sound alert
        })
    
    # Carbon monoxide alert (using thresholds from config)
    mq7_drop = current_data.get('mq7_drop', 0)
    mq7_safe = thresholds.get('mq7', {}).get('safe', 300)
    mq7_high = thresholds.get('mq7', {}).get('high', 750)
    if mq7_drop > mq7_high:
        alerts.append({
            "title": "⚠️ CO CRITICAL",
            "message": f"Carbon monoxide at {mq7_drop:.0f} ppm exceeds safe levels (>{mq7_high}). Ventilate immediately!",
            "timestamp": current_data['timestamp'],
            "sensor_type": "carbon_monoxide",
            "severity": "critical",
            "value": mq7_drop,
            "unit": "ppm",
            "sound": True
        })
    elif mq7_drop > mq7_safe:
        alerts.append({
            "title": "CO Elevated",
            "message": f"Carbon monoxide at {mq7_drop:.0f} ppm. Monitor heating equipment closely.",
            "timestamp": current_data['timestamp'],
            "sensor_type": "carbon_monoxide",
            "severity": "high",
            "value": mq7_drop,
            "unit": "ppm",
            "sound": True
        })
    
    # Flammable gas alert (using thresholds from config)
    mq2_drop = current_data.get('mq2_drop', 0)
    mq2_safe = thresholds.get('mq2', {}).get('safe', 300)
    mq2_high = thresholds.get('mq2', {}).get('high', 750)
    if mq2_drop > mq2_high:
        alerts.append({
            "title": "⚠️ GAS CRITICAL",
            "message": f"Flammable gas at {mq2_drop:.0f} ppm (>{mq2_high}). Check for leaks immediately!",
            "timestamp": current_data['timestamp'],
            "sensor_type": "flammable_gas",
            "severity": "critical",
            "value": mq2_drop,
            "unit": "ppm",
            "sound": True
        })
    elif mq2_drop > mq2_safe:
        alerts.append({
            "title": "Gas Elevated",
            "message": f"Flammable gas at {mq2_drop:.0f} ppm. Increase ventilation.",
            "timestamp": current_data['timestamp'],
            "sensor_type": "flammable_gas",
            "severity": "high",
            "value": mq2_drop,
            "unit": "ppm",
            "sound": True
        })
    
    # ENVIRONMENTAL ALERTS
    
    # Temperature alert (using thresholds from config)
    avg_temp = (current_data['temperature_bmp280'] + current_data['temperature_dht22']) / 2
    temp_opt_min = thresholds.get('temperature', {}).get('optimal', {}).get('min', 20)
    temp_opt_max = thresholds.get('temperature', {}).get('optimal', {}).get('max', 27)
    temp_acc_min = thresholds.get('temperature', {}).get('acceptable', {}).get('min', 18)
    temp_acc_max = thresholds.get('temperature', {}).get('acceptable', {}).get('max', 30)
    
    if avg_temp < temp_acc_min:
        alerts.append({
            "title": "Temperature Critical Low",
            "message": f"Temperature at {avg_temp:.1f}°C is critically low (<{temp_acc_min}°C). Plants may suffer cold damage.",
            "timestamp": current_data['timestamp'],
            "sensor_type": "temperature",
            "severity": "high",
            "value": avg_temp,
            "unit": "°C",
            "sound": True
        })
    elif avg_temp > temp_acc_max:
        alerts.append({
            "title": "Temperature Critical High",
            "message": f"Temperature at {avg_temp:.1f}°C is dangerously high (>{temp_acc_max}°C). Risk of heat stress.",
            "timestamp": current_data['timestamp'],
            "sensor_type": "temperature",
            "severity": "high",
            "value": avg_temp,
            "unit": "°C",
            "sound": True
        })
    elif avg_temp < temp_opt_min or avg_temp > temp_opt_max:
        alerts.append({
            "title": "Temperature Outside Optimal",
            "message": f"Temperature at {avg_temp:.1f}°C is outside optimal range ({temp_opt_min}-{temp_opt_max}°C).",
            "timestamp": current_data['timestamp'],
            "sensor_type": "temperature",
            "severity": "medium",
            "value": avg_temp,
            "unit": "°C",
            "sound": False
        })
    
    # Humidity alert (using thresholds from config)
    humidity = current_data.get('humidity', 0)
    hum_opt_min = thresholds.get('humidity', {}).get('optimal', {}).get('min', 45)
    hum_opt_max = thresholds.get('humidity', {}).get('optimal', {}).get('max', 70)
    hum_acc_min = thresholds.get('humidity', {}).get('acceptable', {}).get('min', 40)
    hum_acc_max = thresholds.get('humidity', {}).get('acceptable', {}).get('max', 80)
    
    if humidity < hum_acc_min:
        alerts.append({
            "title": "Humidity Critical Low",
            "message": f"Humidity at {humidity}% is critically low (<{hum_acc_min}%). Too dry - recommend shading to reduce evaporation.",
            "timestamp": current_data['timestamp'],
            "sensor_type": "humidity",
            "severity": "high",
            "value": humidity,
            "unit": "%",
            "sound": True
        })
    elif humidity > hum_acc_max:
        alerts.append({
            "title": "Humidity Critical High",
            "message": f"Humidity at {humidity}% is dangerously high (>{hum_acc_max}%). Risk of fungal growth - run all ventilation and open vents!",
            "timestamp": current_data['timestamp'],
            "sensor_type": "humidity",
            "severity": "high",
            "value": humidity,
            "unit": "%",
            "sound": True
        })
    elif humidity < hum_opt_min or humidity > hum_opt_max:
        alerts.append({
            "title": "Humidity Outside Optimal",
            "message": f"Humidity at {humidity}% is outside optimal range ({hum_opt_min}-{hum_opt_max}%). Adjust vents/fans.",
            "timestamp": current_data['timestamp'],
            "sensor_type": "humidity",
            "severity": "medium",
            "value": humidity,
            "unit": "%",
            "sound": False
        })
    
    # Air quality alert (using thresholds from config)
    mq135_drop = current_data.get('mq135_drop', 0)
    mq135_good = thresholds.get('mq135', {}).get('good', 200)
    mq135_poor = thresholds.get('mq135', {}).get('poor', 500)
    
    if mq135_drop > mq135_poor:
        alerts.append({
            "title": "Air Quality Poor",
            "message": f"Air quality at {mq135_drop:.0f} ppm indicates poor conditions (>{mq135_poor}). Increase ventilation.",
            "timestamp": current_data['timestamp'],
            "sensor_type": "air_quality",
            "severity": "medium",
            "value": mq135_drop,
            "unit": "ppm",
            "sound": True
        })
    elif mq135_drop > mq135_good:
        alerts.append({
            "title": "Air Quality Moderate",
            "message": f"Air quality at {mq135_drop:.0f} ppm is outside optimal range (>{mq135_good}).",
            "timestamp": current_data['timestamp'],
            "sensor_type": "air_quality",
            "severity": "low",
            "value": mq135_drop,
            "unit": "ppm",
            "sound": False
        })
    
    # Determine if sound alert should be triggered (any critical/high severity)
    should_alert = any(alert.get('sound', False) for alert in alerts)
    
    return jsonify({
        "alerts": alerts,
        "timestamp": current_data['timestamp'],
        "alert_count": len(alerts),
        "should_alert": should_alert  # Frontend can use this to trigger sound
    })

if __name__ == '__main__':
    # Start continuous APEX poller if URL is set
    if ORACLE_APEX_URL:
        poller_thread = threading.Thread(target=continuous_apex_poller, daemon=True)
        poller_thread.start()
        print('✅ Continuous APEX poller started (fetching every 3 seconds)')
        print(f'   Main sensors: {ORACLE_APEX_URL}')
        if ORACLE_APEX_SOIL_URL:
            print(f'   Soil moisture supplement: {ORACLE_APEX_SOIL_URL}')
    else:
        print('⚠️ ORACLE_APEX_URL not set - APEX polling disabled')

    # Start the IP broadcast service in a separate thread
    broadcast_thread = threading.Thread(target=ip_broadcast_service, daemon=True)
    broadcast_thread.start()
    print("IP broadcast service started")

@app.route('/api/export-report', methods=['GET'])
def export_greenhouse_report():
    """Generate comprehensive greenhouse PDF report with AI analysis"""
    try:
        # Get latest APEX data directly
        readings, cache_status = get_cached_apex_or_fetch()
        if not readings:
            return jsonify({'error': 'No APEX data available'}), 503
        
        latest = readings[0]
        sensor_data = {**latest, **build_derived_from_reading(latest)}
        
        # Calculate statuses for all sensors
        temp_avg = (sensor_data.get('temperature_bmp280', 0) + sensor_data.get('temperature_dht22', 0)) / 2
        
        all_analysis = {
            'temperature': {
                'value': temp_avg,
                'status': _get_temperature_status(temp_avg),
                'unit': '°C'
            },
            'humidity': {
                'value': sensor_data.get('humidity', 0),
                'status': _get_humidity_status(sensor_data.get('humidity', 0)),
                'unit': '%'
            },
            'air_quality': {
                'value': sensor_data.get('mq135_drop', 0),
                'status': "Good" if sensor_data.get('mq135_drop', 0) <= 200 else ("Poor" if sensor_data.get('mq135_drop', 0) > 500 else "Moderate"),
                'unit': 'ppm'
            },
            'light': {
                'value': sensor_data.get('light', 0),
                'status': _get_light_status(sensor_data.get('light', 0)),
                'unit': 'lux'
            },
            'co2': {
                'value': sensor_data.get('co2_level', 0),
                'status': _get_co2_status(sensor_data.get('co2_level', 0)),
                'unit': 'ppm'
            },
            'soil_moisture': {
                'value': sensor_data.get('soil_moisture', 0),
                'status': _get_soil_moisture_status(sensor_data.get('soil_moisture', 0)),
                'unit': '%'
            },
            'pressure': {
                'value': sensor_data.get('pressure', 0),
                'status': "Normal" if 990 <= sensor_data.get('pressure', 0) <= 1030 else ("Low" if sensor_data.get('pressure', 0) < 990 else "High"),
                'unit': 'hPa'
            }
        }
        
        # Get AI recommendations
        try:
            ai_recommendations = get_gemini_recommendations(sensor_data)
        except Exception as e:
            logger.warning(f"AI recommendations failed: {e}")
            ai_recommendations = []
        
        # Generate PDF
        buffer = io.BytesIO()
        doc = SimpleDocTemplate(
            buffer, 
            pagesize=letter, 
            rightMargin=50, 
            leftMargin=50, 
            topMargin=50, 
            bottomMargin=50
        )
        
        # Container for PDF elements
        elements = []
        styles = getSampleStyleSheet()
        
        # Define color palette (use soil-toned light surfaces)
        primary_green = colors.HexColor('#2D5016')  # Dark green
        accent_green = colors.HexColor('#4CAF50')   # Light green
        accent_blue = colors.HexColor('#2196F3')    # Blue
        text_dark = colors.HexColor('#333333')      # Dark gray
        bg_soil = colors.HexColor('#F3EEE6')        # Soil light background
        card_soil = colors.HexColor('#FAF4EC')      # Soil card surface
        
        # Custom styles
        title_style = ParagraphStyle(
            'CustomTitle',
            parent=styles['Heading1'],
            fontSize=28,
            textColor=primary_green,
            spaceAfter=8,
            alignment=TA_CENTER,
            fontName='Helvetica-Bold'
        )
        
        subtitle_style = ParagraphStyle(
            'CustomSubtitle',
            parent=styles['Normal'],
            fontSize=14,
            textColor=text_dark,
            spaceAfter=20,
            alignment=TA_CENTER,
            fontName='Helvetica'
        )
        
        heading_style = ParagraphStyle(
            'CustomHeading',
            parent=styles['Heading2'],
            fontSize=16,
            textColor=primary_green,
            spaceAfter=12,
            spaceBefore=20,
            fontName='Helvetica-Bold',
            borderColor=accent_green,
            borderWidth=0,
            borderPadding=8
        )
        
        section_heading_style = ParagraphStyle(
            'SectionHeading',
            parent=styles['Heading3'],
            fontSize=14,
            textColor=primary_green,
            spaceAfter=10,
            spaceBefore=15,
            fontName='Helvetica-Bold'
        )

        # Styles to avoid overlap for large font content
        health_style = ParagraphStyle(
            'HealthStyle',
            parent=styles['Normal'],
            alignment=TA_CENTER,
            leading=56,        # accommodate 48pt number comfortably
            spaceAfter=12,
        )
        alert_cell_style = ParagraphStyle(
            'AlertCell',
            parent=styles['Normal'],
            alignment=TA_CENTER,
            leading=26,        # accommodate 24pt numbers in cells
        )
        
        # Header with logo and branding
        icon_path = os.path.join(os.path.dirname(__file__), 'app_icon.png')
        if os.path.exists(icon_path):
            try:
                logo = Image(icon_path, width=50, height=50)
                # Create header with logo and title side by side
                logo_title_data = [[
                    logo,
                    Paragraph("<b>EcoView</b><br/><font size='8'>Smart Greenhouse Monitoring</font>", 
                             ParagraphStyle('LogoText', parent=styles['Normal'], fontSize=14, 
                                          textColor=primary_green, leftIndent=10))
                ]]
                logo_table = Table(logo_title_data, colWidths=[60, 200])
                logo_table.setStyle(TableStyle([
                    ('ALIGN', (0, 0), (0, 0), 'LEFT'),
                    ('ALIGN', (1, 0), (1, 0), 'LEFT'),
                    ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
                ]))
                elements.append(logo_table)
                elements.append(Spacer(1, 15))
            except Exception as e:
                logger.warning(f"Could not load app icon: {e}")
        
        # Title
        elements.append(Paragraph("Greenhouse Environmental Report", title_style))
        elements.append(Paragraph("Comprehensive Analysis & Recommendations", subtitle_style))
        
        # Report metadata banner - optimized for portrait/mobile viewing
        report_date = datetime.now().strftime('%B %d, %Y at %I:%M %p')
        metadata_data = [[
            Paragraph(f"<b>Report Date:</b><br/>{report_date}", styles['Normal']),
            Paragraph(f"<b>Report ID:</b><br/>{datetime.now().strftime('%Y%m%d-%H%M%S')}", styles['Normal']),
            Paragraph(f"<b>Data Source:</b><br/>Oracle APEX", styles['Normal'])
        ]]
        metadata_table = Table(metadata_data, colWidths=[2.1*inch, 2.1*inch, 2.1*inch])
        metadata_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, -1), card_soil),
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            ('TOPPADDING', (0, 0), (-1, -1), 10),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 10),
            ('BOX', (0, 0), (-1, -1), 1, colors.grey),
            ('LINEBELOW', (0, 0), (-1, -1), 1, colors.white)
        ]))
        elements.append(metadata_table)
        elements.append(Spacer(1, 30))
        
        # Health Score Card
        health_score = _calculate_health_score(all_analysis)
        health_status = "EXCELLENT" if health_score >= 80 else ("GOOD" if health_score >= 60 else "NEEDS ATTENTION")
        health_color = accent_green if health_score >= 80 else (colors.orange if health_score >= 60 else colors.red)
        
        elements.append(Paragraph("Overall Greenhouse Health", heading_style))
        elements.append(Spacer(1, 10))
        health_display = f"""
        <para alignment="center">
            <font size="48" color="{health_color.hexval()}">{health_score}</font>
            <font size="24">/100</font><br/>
            <font size="16" color="{health_color.hexval()}"><b>{health_status}</b></font>
        </para>
        """
        elements.append(Paragraph(health_display, health_style))
        elements.append(Spacer(1, 30))
        
        # Current Conditions - Enhanced Table (portrait-optimized for mobile)
        elements.append(Paragraph("Current Sensor Readings", heading_style))
        elements.append(Spacer(1, 10))
        
        sensor_table_data = [['Sensor', 'Current Value', 'Status', 'Assessment']]
        
        sensor_display_names = {
            'temperature': '🌡️ Temperature',
            'humidity': '💧 Humidity',
            'soil_moisture': '🌱 Soil Moisture',
            'light': '☀️ Light Level',
            'co2': '💨 CO2 Level',
            'air_quality': '🌬️ Air Quality (MQ135)',
            'pressure': '🔽 Pressure'
        }
        
        for sensor_key, data in all_analysis.items():
            status = data['status']
            # Determine status color and symbol
            if status in ['Optimal', 'Good', 'Normal', 'Bright', 'Safe']:
                status_color = accent_green
                symbol = '✓'
            elif status in ['Acceptable', 'Moderate', 'Elevated', 'Dim Indoor']:
                status_color = colors.orange
                symbol = '⚠'
            else:
                status_color = colors.red
                symbol = '✗'
            
            sensor_table_data.append([
                sensor_display_names.get(sensor_key, sensor_key.replace('_', ' ').title()),
                f"{data['value']:.1f} {data['unit']}",
                Paragraph(f"<font color='{status_color.hexval()}'><b>{status}</b></font>", styles['Normal']),
                Paragraph(f"<font size='16' color='{status_color.hexval()}'><b>{symbol}</b></font>", styles['Normal'])
            ])
        
        sensor_table = Table(sensor_table_data, colWidths=[1.9*inch, 1.3*inch, 1.3*inch, 1.1*inch])
        sensor_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), primary_green),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 11),
            ('TOPPADDING', (0, 0), (-1, -1), 10),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 10),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [card_soil, bg_soil])
        ]))
        elements.append(sensor_table)
        elements.append(Spacer(1, 30))
        
        # AI Recommendations Section
        if ai_recommendations:
            elements.append(Paragraph("AI-Powered Recommendations", heading_style))
            elements.append(Spacer(1, 10))
            
            for i, rec in enumerate(ai_recommendations[:6], 1):
                # Handle both dict objects and string representations
                if isinstance(rec, dict):
                    title = rec.get('title', 'Recommendation')
                    description = rec.get('description', '')
                    rec_text = f"""
                    <para leftIndent="20" spaceBefore="5" spaceAfter="10">
                        <font color="{accent_blue.hexval()}"><b>{i}. {title}</b></font><br/>
                        {description}
                    </para>
                    """
                else:
                    # Fallback for string format
                    rec_text = f"""
                    <para leftIndent="20" spaceBefore="5" spaceAfter="5">
                        <font color="{accent_blue.hexval()}"><b>{i}.</b></font> {rec}
                    </para>
                    """
                elements.append(Paragraph(rec_text, styles['Normal']))
            
            elements.append(Spacer(1, 30))
        
        # Alert Summary Section (portrait-optimized)
        elements.append(Paragraph("Alert Summary", heading_style))
        elements.append(Spacer(1, 10))
        alert_summary = _generate_alert_summary(sensor_data)
        critical_count = alert_summary.get('critical_count', 0)
        warning_count = alert_summary.get('warning_count', 0)
        
        alert_data = [[
            Paragraph(f"<b>Critical Alerts</b><br/><font size='24' color='red'>{critical_count}</font>", alert_cell_style),
            Paragraph(f"<b>Warnings</b><br/><font size='24' color='orange'>{warning_count}</font>", alert_cell_style),
            Paragraph(f"<b>Total Sensors</b><br/><font size='24' color='{primary_green.hexval()}'>7</font>", alert_cell_style)
        ]]
        
        alert_table = Table(alert_data, colWidths=[2.1*inch, 2.1*inch, 2.1*inch])
        alert_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, -1), card_soil),
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            ('TOPPADDING', (0, 0), (-1, -1), 15),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 15),
            ('BOX', (0, 0), (-1, -1), 1, colors.grey),
            ('GRID', (0, 0), (-1, -1), 1, colors.white)
        ]))
        elements.append(alert_table)
        elements.append(Spacer(1, 15))
        
        if alert_summary.get('alerts'):
            elements.append(Paragraph("Active Alerts:", section_heading_style))
            elements.append(Spacer(1, 5))
            for alert in alert_summary['alerts'][:8]:
                level_color = colors.red if alert['level'] == 'CRITICAL' else (colors.orange if alert['level'] == 'WARNING' else colors.blue)
                alert_text = f"""
                <para leftIndent="15" spaceBefore="3" spaceAfter="3">
                    <font color="{level_color.hexval()}"><b>[{alert['level']}]</b></font> 
                    <b>{alert['type']}:</b> {alert.get('message', 'Unknown alert')}
                </para>
                """
                elements.append(Paragraph(alert_text, styles['Normal']))
        else:
            elements.append(Paragraph(
                "<para alignment='center'><font color='green'>✅ No active alerts - All systems operating normally</font></para>", 
                styles['Normal']
            ))
        
        elements.append(Spacer(1, 30))
        
        # ===== NEW: DETAILED IMPROVEMENT RECOMMENDATIONS =====
        elements.append(PageBreak())
        elements.append(Paragraph("Detailed Improvement Recommendations", heading_style))
        elements.append(Spacer(1, 15))
        
        # Temperature improvements
        temp_value = all_analysis['temperature']['value']
        temp_status = all_analysis['temperature']['status']
        
        elements.append(Paragraph("🌡️ Temperature Management", section_heading_style))
        elements.append(Spacer(1, 5))
        if temp_status == 'Critical':
            if temp_value < 18:
                temp_advice = """
                <b>URGENT - Temperature Too Low:</b><br/>
                <b>Immediate Actions:</b><br/>
                • Activate heating systems immediately<br/>
                • Close vents and seal any drafts<br/>
                • Use thermal blankets or row covers for sensitive plants<br/>
                • Check for heating system malfunctions<br/>
                <br/>
                <b>Short-term Solutions:</b><br/>
                • Install supplemental heaters (propane, electric, or oil)<br/>
                • Use heat mats for seedlings and young plants<br/>
                • Reduce watering to prevent cold stress<br/>
                <br/>
                <b>Long-term Improvements:</b><br/>
                • Upgrade insulation (bubble wrap on walls, thermal screens)<br/>
                • Install automated heating controls with thermostats<br/>
                • Consider geothermal or solar heating systems<br/>
                • Implement thermal mass (water barrels, concrete blocks) to stabilize temperature
                """
            else:
                temp_advice = """
                <b>URGENT - Temperature Too High:</b><br/>
                <b>Immediate Actions:</b><br/>
                • Open all vents and doors for maximum airflow<br/>
                • Activate exhaust fans at full capacity<br/>
                • Deploy shade cloth (30-50% shade) immediately<br/>
                • Mist plants to cool through evaporation<br/>
                <br/>
                <b>Short-term Solutions:</b><br/>
                • Install evaporative cooling pads<br/>
                • Use oscillating fans to improve air circulation<br/>
                • Paint greenhouse exterior with whitewash or shade paint<br/>
                • Water plants early morning to prevent heat stress<br/>
                <br/>
                <b>Long-term Improvements:</b><br/>
                • Install automated vent openers with temperature sensors<br/>
                • Upgrade to exhaust fans with variable speed controls<br/>
                • Consider retractable shade systems<br/>
                • Install misting or fogging systems for evaporative cooling
                """
        elif temp_status == 'Acceptable':
            if temp_value < 20:
                temp_advice = """
                <b>Temperature Slightly Low:</b><br/>
                • Increase heating gradually by 1-2°C<br/>
                • Close vents during coldest hours (night/early morning)<br/>
                • Monitor overnight temperatures closely<br/>
                • Check heating system efficiency and fuel levels<br/>
                • Consider installing a min/max thermometer to track extremes
                """
            else:
                temp_advice = """
                <b>Temperature Slightly High:</b><br/>
                • Increase ventilation during peak heat hours<br/>
                • Deploy light shade cloth (20-30%)<br/>
                • Ensure adequate air circulation with fans<br/>
                • Water plants adequately to support transpiration cooling<br/>
                • Monitor for heat stress symptoms (wilting, leaf curling)
                """
        else:
            temp_advice = """
            <b>Temperature Optimal:</b><br/>
            • Continue current temperature management practices<br/>
            • Monitor daily fluctuations (aim for 5-10°C day/night differential)<br/>
            • Keep heating and cooling systems maintained<br/>
            • Adjust gradually for different crop stages or seasons
            """
        
        elements.append(Paragraph(temp_advice, styles['Normal']))
        elements.append(Spacer(1, 20))
        
        # Humidity improvements
        humidity_value = all_analysis['humidity']['value']
        humidity_status = all_analysis['humidity']['status']
        
        elements.append(Paragraph("💧 Humidity Control", section_heading_style))
        elements.append(Spacer(1, 5))
        if humidity_value < 45:
            humidity_advice = """
            <b>URGENT - Humidity Too Low:</b><br/>
            <b>Immediate Actions:</b><br/>
            • Increase watering frequency<br/>
            • Mist plants 2-3 times daily<br/>
            • Place water trays near heating sources for evaporation<br/>
            • Reduce ventilation temporarily<br/>
            <br/>
            <b>Short-term Solutions:</b><br/>
            • Install a portable humidifier<br/>
            • Use wet burlap or shade cloth to increase humidity<br/>
            • Group plants together to create microclimates<br/>
            • Mulch soil to retain moisture<br/>
            <br/>
            <b>Long-term Improvements:</b><br/>
            • Install automated misting/fogging system<br/>
            • Add evaporative cooling pads<br/>
            • Improve greenhouse sealing to prevent moisture loss<br/>
            • Consider hydroponics or aquaponics to increase ambient humidity
            """
        elif humidity_value > 80:
            humidity_advice = """
            <b>URGENT - Humidity Too High:</b><br/>
            <b>Immediate Actions:</b><br/>
            • Increase ventilation immediately (fans + open vents)<br/>
            • Reduce watering frequency<br/>
            • Space plants further apart for better airflow<br/>
            • Remove any standing water<br/>
            <br/>
            <b>Short-term Solutions:</b><br/>
            • Install dehumidifier if available<br/>
            • Prune dense foliage to improve air circulation<br/>
            • Water only in the morning (never at night)<br/>
            • Check for leaks or excess condensation<br/>
            <br/>
            <b>Long-term Improvements:</b><br/>
            • Install circulation fans for continuous air movement<br/>
            • Upgrade to automated exhaust fans with humidity sensors<br/>
            • Implement thermal screens to manage condensation<br/>
            • Ensure proper greenhouse design (slope, gutters for drainage)<br/>
            • Consider horizontal airflow (HAF) fan systems
            """
        elif humidity_value > 70:
            humidity_advice = """
            <b>Humidity Slightly High:</b><br/>
            • Increase ventilation, especially during high-humidity periods<br/>
            • Run circulation fans continuously<br/>
            • Monitor for signs of fungal disease (powdery mildew, botrytis)<br/>
            • Avoid overhead watering; use drip irrigation instead<br/>
            • Inspect plants regularly for mold or mildew
            """
        else:
            humidity_advice = """
            <b>Humidity Optimal:</b><br/>
            • Maintain current ventilation and watering practices<br/>
            • Continue monitoring for disease pressure<br/>
            • Adjust humidity for specific crop requirements<br/>
            • Keep records of humidity patterns for seasonal planning
            """
        
        elements.append(Paragraph(humidity_advice, styles['Normal']))
        elements.append(Spacer(1, 20))
        
        # Soil Moisture improvements
        soil_moisture_value = all_analysis['soil_moisture']['value']
        soil_moisture_status = all_analysis['soil_moisture']['status']
        
        elements.append(Paragraph("🌱 Soil Moisture Management", section_heading_style))
        elements.append(Spacer(1, 5))
        if soil_moisture_value < 30:
            soil_advice = """
            <b>URGENT - Soil Moisture Too Low:</b><br/>
            <b>Immediate Actions:</b><br/>
            • Water plants immediately with room-temperature water<br/>
            • Check irrigation system for malfunctions or clogs<br/>
            • Inspect soil for hydrophobic conditions (water running off surface)<br/>
            • Add mulch to reduce evaporation<br/>
            • Move sensitive plants to shadier areas temporarily<br/>
            <br/>
            <b>Short-term Solutions:</b><br/>
            • Increase watering frequency or duration<br/>
            • Add wetting agent to soil if hydrophobic<br/>
            • Check for root damage or soil compaction<br/>
            • Apply organic matter or compost to improve water retention<br/>
            • Group plants by water needs for efficient irrigation<br/>
            <br/>
            <b>Long-term Improvements:</b><br/>
            • Install automated drip irrigation with timers<br/>
            • Add soil moisture sensors for real-time monitoring<br/>
            • Improve soil structure with organic amendments (compost, peat, coco coir)<br/>
            • Install smart controllers that adjust watering based on sensor data<br/>
            • Consider sub-irrigation or self-watering systems<br/>
            • Apply 2-3 inch mulch layer to retain moisture
            """
        elif soil_moisture_value > 70:
            soil_advice = """
            <b>URGENT - Soil Moisture Too High:</b><br/>
            <b>Immediate Actions:</b><br/>
            • Stop all watering immediately<br/>
            • Improve drainage by tilting pots or adding drain holes<br/>
            • Increase air circulation around root zone<br/>
            • Check for standing water beneath containers<br/>
            • Remove waterlogged plants to prevent root rot<br/>
            <br/>
            <b>Short-term Solutions:</b><br/>
            • Reduce watering frequency and duration<br/>
            • Improve drainage with perlite, sand, or gravel amendments<br/>
            • Elevate containers on pot feet or blocks<br/>
            • Inspect for root rot (brown, mushy roots) and trim if necessary<br/>
            • Increase ventilation to promote evaporation<br/>
            • Check irrigation system for leaks or stuck valves<br/>
            <br/>
            <b>Long-term Improvements:</b><br/>
            • Install proper drainage systems (French drains, gravel beds)<br/>
            • Use well-draining soil mixes (30-40% perlite/pumice)<br/>
            • Implement raised beds or benches for better drainage<br/>
            • Install soil moisture sensors to prevent overwatering<br/>
            • Use moisture meters before watering decisions<br/>
            • Consider drip irrigation with pressure-compensating emitters<br/>
            • Ensure proper greenhouse slope for water runoff
            """
        elif soil_moisture_value < 40:
            soil_advice = """
            <b>Soil Moisture Slightly Low:</b><br/>
            • Increase watering frequency by 10-20%<br/>
            • Check soil moisture at root depth (2-4 inches), not just surface<br/>
            • Add thin mulch layer to reduce evaporation<br/>
            • Monitor plants for wilting, especially during hot periods<br/>
            • Consider installing moisture sensors for precise monitoring<br/>
            • Water early morning for best absorption
            """
        elif soil_moisture_value > 60:
            soil_advice = """
            <b>Soil Moisture Slightly High:</b><br/>
            • Reduce watering frequency by 10-20%<br/>
            • Ensure adequate drainage in containers and beds<br/>
            • Increase air circulation to promote evaporation<br/>
            • Monitor for signs of overwatering (yellowing leaves, wilting despite wet soil)<br/>
            • Check root health if problems persist<br/>
            • Allow soil to dry slightly between waterings
            """
        else:
            soil_advice = """
            <b>Soil Moisture Optimal:</b><br/>
            • Continue current watering practices<br/>
            • Maintain consistent moisture levels for best growth<br/>
            • Monitor seasonal changes and adjust as needed<br/>
            • Keep records of watering patterns for future reference<br/>
            • Adjust for different plant growth stages (seedlings need less, fruiting plants need more)<br/>
            • Regular soil testing to ensure proper nutrient availability
            """
        
        elements.append(Paragraph(soil_advice, styles['Normal']))
        elements.append(Spacer(1, 20))
        
        # Air Quality and Gas Sensors
        air_quality_value = all_analysis['air_quality']['value']
        air_quality_status = all_analysis['air_quality']['status']
        
        elements.append(Paragraph("🌬️ Air Quality & Gas Management", section_heading_style))
        elements.append(Spacer(1, 5))
        
        if air_quality_status == 'Poor':
            air_advice = """
            <b>URGENT - Poor Air Quality Detected:</b><br/>
            <b>Immediate Actions:</b><br/>
            • Maximize ventilation (open all vents, run exhaust fans)<br/>
            • Evacuate personnel if CO or flammable gas levels are high<br/>
            • Check for combustion sources (heaters, generators)<br/>
            • Inspect for chemical spills or decomposing organic matter<br/>
            <br/>
            <b>Investigation Steps:</b><br/>
            • Test gas heaters and ensure proper venting<br/>
            • Check for propane/natural gas leaks<br/>
            • Inspect compost piles or organic fertilizers (ammonia, methane)<br/>
            • Look for mold or mildew growth<br/>
            • Verify air filters are clean and functional<br/>
            <br/>
            <b>Long-term Solutions:</b><br/>
            • Install CO and gas detectors with alarms<br/>
            • Ensure all combustion equipment is properly vented to exterior<br/>
            • Use electric heating where possible<br/>
            • Implement air filtration systems<br/>
            • Schedule regular air quality testing
            """
        elif air_quality_status == 'Moderate':
            air_advice = """
            <b>Air Quality - Moderate Concern:</b><br/>
            • Increase fresh air exchange (open vents more frequently)<br/>
            • Run circulation fans to prevent stagnant air pockets<br/>
            • Check and clean air filters<br/>
            • Inspect heating equipment for incomplete combustion<br/>
            • Monitor for changes; retest in 1-2 hours
            """
        else:
            air_advice = """
            <b>Air Quality - Good:</b><br/>
            • Maintain current ventilation practices<br/>
            • Continue routine equipment inspections<br/>
            • Keep gas sensors calibrated (replace every 2-3 years)<br/>
            • Ensure adequate fresh air exchange (0.5-1.5 air changes/minute)
            """
        
        # Add MQ2 and MQ7 specific advice
        mq2_value = sensor_data.get('mq2_drop', 0)
        mq7_value = sensor_data.get('mq7_drop', 0)
        
        if mq2_value > 750:
            air_advice += """<br/><br/>
            <b>⚠️ DANGER - High Flammable Gas Detected (MQ2 > 750 ppm):</b><br/>
            • EVACUATE IMMEDIATELY<br/>
            • Shut off gas supply valves<br/>
            • Eliminate all ignition sources (no smoking, sparks, flames)<br/>
            • Do not operate electrical switches<br/>
            • Call emergency services if unable to locate/stop leak<br/>
            • Ventilate area extensively before re-entry
            """
        elif mq2_value > 300:
            air_advice += """<br/><br/>
            <b>⚠️ WARNING - Elevated Flammable Gas (MQ2 > 300 ppm):</b><br/>
            • Check propane tanks, gas lines, and connections for leaks<br/>
            • Inspect pilot lights and burners on heaters<br/>
            • Increase ventilation and monitor continuously<br/>
            • Restrict ignition sources until levels drop
            """
        
        if mq7_value > 750:
            air_advice += """<br/><br/>
            <b>⚠️ DANGER - High Carbon Monoxide Detected (MQ7 > 750 ppm):</b><br/>
            • EVACUATE ALL PERSONNEL IMMEDIATELY<br/>
            • Shut down all combustion equipment<br/>
            • Open all doors and vents for maximum ventilation<br/>
            • Seek medical attention if symptoms present (headache, dizziness, nausea)<br/>
            • Call emergency services<br/>
            • Have heating equipment professionally inspected before restart
            """
        elif mq7_value > 300:
            air_advice += """<br/><br/>
            <b>⚠️ WARNING - Elevated Carbon Monoxide (MQ7 > 300 ppm):</b><br/>
            • Shut down gas heaters and inspect for incomplete combustion<br/>
            • Check exhaust flues and chimneys for blockages<br/>
            • Ensure adequate combustion air supply<br/>
            • Ventilate area and monitor levels<br/>
            • Consider installing CO alarms if not present
            """
        
        elements.append(Paragraph(air_advice, styles['Normal']))
        elements.append(Spacer(1, 30))
        
        # ===== NEW: TROUBLESHOOTING GUIDE =====
        elements.append(PageBreak())
        elements.append(Paragraph("Troubleshooting Guide", heading_style))
        elements.append(Paragraph(
            "Common issues and their solutions for optimal greenhouse management:",
            subtitle_style
        ))
        elements.append(Spacer(1, 15))
        
        troubleshooting_sections = [
            {
                "title": "🌡️ Temperature Won't Stabilize",
                "symptoms": "Frequent temperature swings, difficulty maintaining target range",
                "causes": [
                    "<b>Poor insulation:</b> Heat loss through walls, roof, or foundation",
                    "<b>Inadequate thermal mass:</b> Lack of heat storage capacity",
                    "<b>Undersized/oversized equipment:</b> HVAC not matched to greenhouse size",
                    "<b>Air leaks:</b> Drafts from doors, vents, or structural gaps"
                ],
                "solutions": [
                    "Add insulation: bubble wrap on walls, thermal curtains, weather stripping",
                    "Install thermal mass: 55-gallon water drums painted black, gravel beds, concrete blocks",
                    "Upgrade to appropriately sized heating/cooling systems",
                    "Seal all air leaks with caulk or weatherstripping",
                    "Use automated controllers with temperature sensors for consistent management"
                ],
                "prevention": "Regular maintenance of HVAC systems, annual insulation inspections, proper greenhouse design with adequate thermal mass"
            },
            {
                "title": "💧 Humidity Too High (Persistent)",
                "symptoms": "Constant condensation, mold/mildew growth, fungal diseases",
                "causes": [
                    "<b>Poor air circulation:</b> Stagnant air pockets allowing moisture buildup",
                    "<b>Overwatering:</b> Excess soil moisture evaporating into air",
                    "<b>Inadequate ventilation:</b> Insufficient fresh air exchange",
                    "<b>Night condensation:</b> Temperature drops causing moisture release"
                ],
                "solutions": [
                    "Install horizontal airflow (HAF) fans for continuous circulation",
                    "Reduce watering frequency; use drip irrigation instead of overhead",
                    "Increase ventilation during high-humidity periods (early morning, evening)",
                    "Use thermal screens to prevent night condensation",
                    "Install dehumidifier for extreme cases",
                    "Space plants further apart; prune dense foliage"
                ],
                "prevention": "Proper greenhouse design with ridge vents, side vents, and fans; regular monitoring; avoiding evening watering"
            },
            {
                "title": "💨 CO2 Levels Low or Unstable",
                "symptoms": "Slow plant growth, CO2 readings below 400 ppm, enrichment not effective",
                "causes": [
                    "<b>Excessive ventilation:</b> Fresh air exchange removing enriched CO2",
                    "<b>Leaks in system:</b> CO2 escaping before reaching plants",
                    "<b>Poor distribution:</b> Uneven CO2 levels across greenhouse",
                    "<b>Timing issues:</b> CO2 released when stomata are closed"
                ],
                "solutions": [
                    "Balance ventilation: enrich CO2 during low-ventilation periods (early morning)",
                    "Check CO2 distribution system for leaks and proper placement",
                    "Use circulation fans to distribute CO2 evenly",
                    "Release CO2 during photosynthesis hours (sunrise to 2-3 hours before sunset)",
                    "Install CO2 sensors to monitor and control enrichment automatically",
                    "Consider burner or generator systems for larger operations"
                ],
                "prevention": "Regular system inspections, calibrate sensors annually, maintain 1000-1500 ppm during active growth"
            },
            {
                "title": "🌬️ Poor Air Quality Persists",
                "symptoms": "High gas readings (MQ135/MQ2/MQ7), odors, plant stress despite ventilation",
                "causes": [
                    "<b>Combustion equipment issues:</b> Incomplete burning producing CO",
                    "<b>Gas leaks:</b> Propane or natural gas escaping from lines",
                    "<b>Decomposing organic matter:</b> Compost or wet soil producing ammonia/methane",
                    "<b>Chemical contamination:</b> Pesticides, paints, or cleaners releasing VOCs"
                ],
                "solutions": [
                    "Inspect and service all combustion equipment (heaters, generators)",
                    "Perform leak test on gas lines with soapy water or detector",
                    "Move compost piles away from greenhouse; ensure proper aeration",
                    "Remove or properly store chemicals; ventilate after application",
                    "Install air filtration system with activated carbon filters",
                    "Switch to electric heating if gas issues persist"
                ],
                "prevention": "Annual equipment servicing, proper chemical storage, adequate ventilation, regular gas sensor calibration"
            },
            {
                "title": "☀️ Light Levels Inadequate",
                "symptoms": "Leggy plants, slow growth, poor flowering/fruiting, low lux readings",
                "causes": [
                    "<b>Dirty glazing:</b> Algae, dust, or mineral deposits blocking light",
                    "<b>Shading:</b> Nearby structures, trees, or shade cloth during low-light seasons",
                    "<b>Short day length:</b> Insufficient natural light in winter",
                    "<b>Glazing degradation:</b> Old plastic or glass with reduced transmittance"
                ],
                "solutions": [
                    "Clean greenhouse glazing regularly (monthly minimum)",
                    "Remove or trim nearby vegetation blocking light",
                    "Remove shade cloth during low-light months (fall/winter)",
                    "Install supplemental LED grow lights (full-spectrum, 12-16 hours/day)",
                    "Replace old glazing with high-transmittance materials",
                    "Use reflective mulches or white paint to increase light reflection"
                ],
                "prevention": "Regular cleaning schedule, proper greenhouse orientation (east-west for year-round), quality glazing materials"
            },
            {
                "title": "🌱 Soil Moisture Inconsistent",
                "symptoms": "Some areas too wet, others too dry; uneven plant growth",
                "causes": [
                    "<b>Uneven watering:</b> Manual watering missing spots or over-saturating areas",
                    "<b>Soil variation:</b> Different soil types retaining water differently",
                    "<b>Drainage issues:</b> Poor drainage creating waterlogged zones",
                    "<b>Irrigation system problems:</b> Clogged emitters or broken lines"
                ],
                "solutions": [
                    "Install drip irrigation with pressure-compensating emitters",
                    "Use soil moisture sensors in multiple zones",
                    "Amend soil with compost or perlite to improve consistency",
                    "Ensure proper drainage with gravel beds or slope",
                    "Flush and inspect irrigation lines regularly",
                    "Group plants by water needs"
                ],
                "prevention": "Uniform soil preparation, automated irrigation with sensors, regular system maintenance"
            }
        ]
        
        for section in troubleshooting_sections:
            elements.append(Paragraph(section["title"], section_heading_style))
            elements.append(Spacer(1, 5))
            elements.append(Paragraph(f"<b>Symptoms:</b> {section['symptoms']}", styles['Normal']))
            elements.append(Spacer(1, 5))
        
            causes_text = "<b>Possible Causes:</b><br/>" + "<br/>".join([f"• {cause}" for cause in section['causes']])
            elements.append(Paragraph(causes_text, styles['Normal']))
            elements.append(Spacer(1, 5))
        
            solutions_text = "<b>Solutions:</b><br/>" + "<br/>".join([f"• {sol}" for sol in section['solutions']])
            elements.append(Paragraph(solutions_text, styles['Normal']))
            elements.append(Spacer(1, 5))
        
            elements.append(Paragraph(f"<b>Prevention:</b> {section['prevention']}", styles['Normal']))
            elements.append(Spacer(1, 20))
        
        # Historical Data Summary - New Page (portrait-optimized)
        elements.append(PageBreak())
        elements.append(Paragraph("Recent Historical Data", heading_style))
        elements.append(Paragraph(f"Last {min(24, len(readings))} readings from APEX database", styles['Normal']))
        elements.append(Spacer(1, 15))
        
        history_table_data = [['Time', 'Temp\n(°C)', 'Humidity\n(%)', 'Soil\n(%)', 'Light\n(lux)', 'CO2\n(ppm)']]
        for reading in readings[:24]:
            # Merge raw reading with derived data to get calculated fields like light and co2_level
            reading_data = {**reading, **build_derived_from_reading(reading)}
            
            timestamp = datetime.fromtimestamp(reading_data.get('timestamp', time.time())).strftime('%m/%d %H:%M')
            temp = (reading_data.get('temperature_bmp280', 0) + reading_data.get('temperature_dht22', 0)) / 2
            humidity = reading_data.get('humidity', 0)
            # Get soil moisture from multiple possible field names
            soil_moisture = reading_data.get('sloi_moisture') or reading_data.get('moisture') or reading_data.get('soil_moisture', 0)
            light = reading_data.get('light', 0)
            co2 = reading_data.get('co2_level', 0)
            history_table_data.append([
                timestamp, 
                f"{temp:.1f}", 
                f"{humidity:.1f}",
                f"{soil_moisture:.1f}",
                f"{light:.0f}",
                f"{co2:.0f}"
            ])
        
        history_table = Table(history_table_data, colWidths=[1*inch, 0.75*inch, 0.75*inch, 0.65*inch, 0.85*inch, 0.85*inch])
        history_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), accent_blue),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 9),
            ('FONTSIZE', (0, 1), (-1, -1), 8),
            ('TOPPADDING', (0, 0), (-1, -1), 6),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [card_soil, bg_soil])
        ]))
        elements.append(history_table)
        
        # Additional Sensor Details (portrait-optimized)
        elements.append(Spacer(1, 30))
        elements.append(Paragraph("Gas Sensor Readings", heading_style))
        
        gas_data = [
            ['Sensor', 'Reading (ppm)', 'Status', 'Safety Level'],
            [
                'MQ135 (Air Quality)', 
                f"{sensor_data.get('mq135_drop', 0):.0f}",
                all_analysis['air_quality']['status'],
                '✓ Safe' if sensor_data.get('mq135_drop', 0) <= 200 else ('⚠ Caution' if sensor_data.get('mq135_drop', 0) <= 500 else '✗ Poor')
            ],
            [
                'MQ2 (Flammable Gas)',
                f"{sensor_data.get('mq2_drop', 0):.0f}",
                "Safe" if sensor_data.get('mq2_drop', 0) <= 300 else ("Elevated" if sensor_data.get('mq2_drop', 0) <= 750 else "High"),
                '✓ Safe' if sensor_data.get('mq2_drop', 0) <= 300 else ('⚠ Caution' if sensor_data.get('mq2_drop', 0) <= 750 else '✗ Danger')
            ],
            [
                'MQ7 (Carbon Monoxide)',
                f"{sensor_data.get('mq7_drop', 0):.0f}",
                "Safe" if sensor_data.get('mq7_drop', 0) <= 300 else ("Elevated" if sensor_data.get('mq7_drop', 0) <= 750 else "High"),
                '✓ Safe' if sensor_data.get('mq7_drop', 0) <= 300 else ('⚠ Caution' if sensor_data.get('mq7_drop', 0) <= 750 else '✗ Danger')
            ]
        ]
        
        gas_table = Table(gas_data, colWidths=[1.85*inch, 1.35*inch, 1.3*inch, 1.2*inch])
        gas_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), primary_green),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 10),
            ('TOPPADDING', (0, 0), (-1, -1), 8),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [card_soil, bg_soil])
        ]))
        elements.append(gas_table)
        
        # Footer with branding
        elements.append(Spacer(1, 40))
        footer_line = Table([['']], colWidths=[6*inch])
        footer_line.setStyle(TableStyle([
            ('LINEABOVE', (0, 0), (-1, 0), 2, accent_green),
        ]))
        elements.append(footer_line)
        elements.append(Spacer(1, 10))
        
        footer_text = f"""
        <para alignment="center">
            <font size="10" color="{text_dark.hexval()}">
                <i>Generated by <b>EcoView Greenhouse Monitoring System</b></i><br/>
                Smart monitoring for optimal plant growth and environmental control<br/>
                Report ID: {datetime.now().strftime('%Y%m%d%H%M%S')} | Data Source: Oracle APEX
            </font>
        </para>
        """
        elements.append(Paragraph(footer_text, styles['Normal']))
        
        # Build PDF
        doc.build(elements)
        buffer.seek(0)
        
        # Generate filename
        filename = f"EcoView_Report_{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.pdf"
        
        return send_file(
            buffer,
            as_attachment=True,
            download_name=filename,
            mimetype='application/pdf'
        )
        
    except Exception as e:
        logger.error(f"Error generating PDF report: {e}")
        traceback.print_exc()
        return jsonify({'error': str(e), 'trace': traceback.format_exc()}), 500

def _generate_overview(sensor_data, analysis):
    """Generate greenhouse overview summary"""
    
    overview = {
        'status': 'OPERATIONAL',
        'monitoring_since': sensor_data.get('timestamp', time.time()),
        'total_sensors': 11,
        'active_sensors': 8,  # Count non-null sensors
        'summary': ''
    }
    
    # Generate summary text
    temp_status = analysis.get('temperature', {}).get('status', 'Unknown')
    humidity_status = analysis.get('humidity', {}).get('status', 'Unknown')
    air_status = analysis.get('air_quality', {}).get('status', 'Unknown')
    light_status = analysis.get('light', {}).get('status', 'Unknown')
    
    summary_parts = []
    if temp_status == 'Optimal':
        summary_parts.append("Temperature is in optimal range")
    elif temp_status == 'Critical':
        summary_parts.append("⚠️ CRITICAL: Temperature requires immediate attention")
    else:
        summary_parts.append(f"Temperature is {temp_status}")
    
    if humidity_status == 'Optimal':
        summary_parts.append("humidity is ideal")
    elif humidity_status == 'Critical':
        summary_parts.append("⚠️ humidity needs urgent correction")
    else:
        summary_parts.append(f"humidity is {humidity_status}")
    
    if air_status == 'Good':
        summary_parts.append("air quality is excellent")
    elif air_status == 'Poor':
        summary_parts.append("⚠️ poor air quality detected")
    
    if light_status in ['Bright', 'Moderate']:
        summary_parts.append(f"lighting is {light_status.lower()}")
    elif light_status in ['Dark Night', 'Low Light']:
        summary_parts.append(f"low light conditions ({light_status})")
    
    overview['summary'] = ', '.join(summary_parts).capitalize() + '.'
    
    return overview

def _generate_current_conditions(sensor_data):
    """Generate current conditions summary"""
    
    return {
        'temperature': {
            'bmp280': sensor_data.get('temperature_bmp280', 0),
            'dht22': sensor_data.get('temperature_dht22', 0),
            'average': (sensor_data.get('temperature_bmp280', 0) + sensor_data.get('temperature_dht22', 0)) / 2
        },
        'humidity': sensor_data.get('humidity', 0),
        'air_quality': {
            'mq135_co2': sensor_data.get('mq135_drop', 0),
            'mq2_gas': sensor_data.get('mq2_drop', 0),
            'mq7_co': sensor_data.get('mq7_drop', 0)
        },
        'atmospheric': {
            'pressure': sensor_data.get('pressure', 0),
            'altitude': sensor_data.get('altitude', 0)
        },
        'light_intensity': sensor_data.get('light', 0),
        'flame_detection': sensor_data.get('flame_status', 'Unknown')
    }

def _generate_alert_summary(sensor_data):
    """Generate alert summary"""
    alerts = []
    
    # Temperature alerts (20-27°C optimal)
    temp_avg = (sensor_data.get('temperature_bmp280', 0) + sensor_data.get('temperature_dht22', 0)) / 2
    if temp_avg < 18:
        alerts.append({'level': 'CRITICAL', 'type': 'Temperature', 'message': f'Temperature too low: {temp_avg:.1f}°C'})
    elif temp_avg > 30:
        alerts.append({'level': 'CRITICAL', 'type': 'Temperature', 'message': f'Temperature too high: {temp_avg:.1f}°C'})
    elif temp_avg < 20 or temp_avg > 27:
        alerts.append({'level': 'WARNING', 'type': 'Temperature', 'message': f'Temperature suboptimal: {temp_avg:.1f}°C'})
    
    # Humidity alerts (45-70% optimal)
    humidity = sensor_data.get('humidity', 0)
    if humidity < 45:
        alerts.append({'level': 'CRITICAL', 'type': 'Humidity', 'message': f'Too dry: {humidity}% - Add shading'})
    elif humidity > 80:
        alerts.append({'level': 'CRITICAL', 'type': 'Humidity', 'message': f'Too humid: {humidity}% - Run ventilation'})
    elif humidity > 70:
        alerts.append({'level': 'WARNING', 'type': 'Humidity', 'message': f'Slightly high: {humidity}%'})
    
    # Air quality alerts (200/500 thresholds)
    mq135 = sensor_data.get('mq135_drop', 0)
    if mq135 > 500:
        alerts.append({'level': 'WARNING', 'type': 'Air Quality', 'message': f'Poor air quality: {mq135:.0f} PPM'})
    elif mq135 > 200:
        alerts.append({'level': 'INFO', 'type': 'Air Quality', 'message': f'Moderate air quality: {mq135:.0f} PPM'})
    
    # Gas alerts
    mq2 = sensor_data.get('mq2_drop', 0)
    if mq2 > 750:
        alerts.append({'level': 'CRITICAL', 'type': 'Flammable Gas', 'message': f'High gas level: {mq2:.0f} PPM'})
    elif mq2 > 300:
        alerts.append({'level': 'WARNING', 'type': 'Flammable Gas', 'message': f'Elevated gas: {mq2:.0f} PPM'})
    
    # CO alerts
    mq7 = sensor_data.get('mq7_drop', 0)
    if mq7 > 750:
        alerts.append({'level': 'CRITICAL', 'type': 'Carbon Monoxide', 'message': f'High CO: {mq7:.0f} PPM'})
    elif mq7 > 300:
        alerts.append({'level': 'WARNING', 'type': 'Carbon Monoxide', 'message': f'Elevated CO: {mq7:.0f} PPM'})
    
    # Flame detection
    if sensor_data.get('flame_detected'):
        alerts.append({'level': 'CRITICAL', 'type': 'FIRE', 'message': '⚠️ FIRE DETECTED'})
    
    return {
        'total_alerts': len(alerts),
        'critical_count': sum(1 for a in alerts if a['level'] == 'CRITICAL'),
        'warning_count': sum(1 for a in alerts if a['level'] == 'WARNING'),
        'alerts': alerts
    }

def _calculate_health_score(analysis):
    """Calculate overall greenhouse health score (0-100)"""
    score = 100
    
    # Temperature impact
    temp_status = analysis.get('temperature', {}).get('status', '')
    if temp_status == 'Critical':
        score -= 30
    elif temp_status == 'Acceptable':
        score -= 10
    
    # Humidity impact
    humidity_status = analysis.get('humidity', {}).get('status', '')
    if humidity_status == 'Critical':
        score -= 30
    elif humidity_status == 'Acceptable':
        score -= 10
    
    # Air quality impact
    air_status = analysis.get('air_quality', {}).get('status', '')
    if air_status == 'Poor':
        score -= 20
    elif air_status == 'Moderate':
        score -= 10
    
    # Light impact
    light_status = analysis.get('light', {}).get('status', '')
    if light_status in ['Dark Night', 'Low Light']:
        score -= 15
    elif light_status == 'Dim Indoor':
        score -= 5
    
    return max(0, min(100, score))

if __name__ == '__main__':
    # For development only - use gunicorn in production
    app.run(host='0.0.0.0', port=5000, debug=True)