# Enrique Saturday Testing - Bridge Utility (MQTT <-> Oracle APEX)

## Overview
This standalone script can run in two modes to help you test live data flows without touching the main app:

- mqtt_to_apex: Subscribe to your MQTT broker (ESP32 publishes) and forward to Oracle APEX (POST)
- apex_to_mqtt: Poll Oracle APEX (GET) for latest readings and optionally publish them to MQTT

**IMPORTANT:** This script is completely separate from your main application and will not affect any existing code.

## What It Does
Depending on the mode:

1) mqtt_to_apex
  - Connects to your MQTT broker
  - Subscribes to your ESP32's sensor data topic
  - Receives live JSON sensor readings
  - Validates payload structure
  - Posts the data to your Oracle APEX POST endpoint
  - Logs all activity with timestamps

2) apex_to_mqtt
  - Calls your Oracle APEX GET endpoint periodically
  - Parses the response and picks the latest reading
  - Validates payload structure
  - Publishes the reading to an MQTT topic (optional) and always logs values

## Prerequisites
- Python 3.7 or higher
- pip (Python package manager)
- Network access to both MQTT broker and Oracle APEX

## Installation

### Step 1: Install Dependencies
```powershell
# Navigate to the project root
cd "c:\Users\abara\Documents\Campus work\IFS 325\Greenhouse project\Greenhouse app\Gemini final\sturdy-giggle"

# Install required packages
pip install -r mqtt_bridge_requirements.txt
```

Or install manually:
```powershell
pip install paho-mqtt==1.6.1 requests==2.31.0
```

### Step 2: Configure the Script
Open `enrique_saturday_testing.py` and update the **CONFIGURATION** section (MQTT and APEX settings):

```python
# MQTT Broker Configuration
MQTT_BROKER = "your-broker-address.com"  # Your MQTT broker IP/hostname
MQTT_PORT = 1883                          # Default MQTT port
MQTT_TOPIC = "greenhouse/sensors"         # Topic your ESP32 publishes to
MQTT_USERNAME = None                      # Set if broker requires auth
MQTT_PASSWORD = None                      # Set if broker requires auth

# Oracle APEX REST Endpoints
APEX_POST_URL = "https://apex.oracle.com/pls/apex/your_workspace/your_schema/sensor_readings"  # POST handler
APEX_GET_URL  = "https://apex.oracle.com/pls/apex/your_workspace/your_schema/sensor_readings"  # GET handler
```

**Required Changes:**
- `MQTT_BROKER`: Your broker address (e.g., `"192.168.1.100"` or `"broker.hivemq.com"`)
- `MQTT_TOPIC`: The exact topic your ESP32 publishes to
- `APEX_POST_URL`: Your Oracle APEX POST endpoint URL (for mqtt_to_apex)
- `APEX_GET_URL`: Your Oracle APEX GET endpoint URL (for apex_to_mqtt)

**Optional Changes:**
- `MQTT_USERNAME` / `MQTT_PASSWORD`: If your broker requires authentication
- `VERBOSE`: Set to `False` to reduce console output
- `MAX_RETRIES`: Number of retry attempts for failed APEX posts

## ESP32 Payload Format
Your ESP32 should publish JSON in this format:
```json
{
  "timestamp": 1698825600,
  "temperature_bmp280": 24.5,
  "temperature_dht22": 24.3,
  "pressure": 1013.25,
  "altitude": 120.5,
  "humidity": 65.2,
  "flame_raw": 512,
  "flame_detected": 0,
  "light_raw": 850,
  "mq135_raw": 300,
  "mq135_baseline": 250,
  "mq135_drop": 50,
  "mq2_raw": 280,
  "mq2_baseline": 260,
  "mq2_drop": 20,
  "mq7_raw": 310,
  "mq7_baseline": 290,
  "mq7_drop": 20
}
```

**Note:** The script will add a Unix timestamp if your ESP32 doesn't include one.

## Running the Bridge

### Start the Bridge (mqtt_to_apex)
```powershell
# Navigate to the project root
cd "c:\Users\abara\Documents\Campus work\IFS 325\Greenhouse project\Greenhouse app\Gemini final\sturdy-giggle"

# Run the bridge script (subscribe to MQTT and forward to APEX)
python enrique_saturday_testing.py --mode mqtt_to_apex
```

### Expected Output (mqtt_to_apex)
```
======================================================================
  Bridge Utility: MQTT <-> Oracle APEX
  Mode: mqtt_to_apex
======================================================================

[2025-11-01 14:30:00] [INFO] MQTT Broker:  broker.hivemq.com:1883
[2025-11-01 14:30:00] [INFO] MQTT Topic:   greenhouse/sensors
[2025-11-01 14:30:00] [INFO] APEX Endpoint: https://apex.oracle.com/...
[2025-11-01 14:30:00] [INFO] Connecting to MQTT broker...
[2025-11-01 14:30:01] [INFO] ✓ Connected to MQTT broker
[2025-11-01 14:30:01] [INFO] ✓ Subscribed successfully. Waiting for sensor data...

[2025-11-01 14:30:15] [INFO] 📩 Received message on topic 'greenhouse/sensors'
[2025-11-01 14:30:15] [INFO] ────────────────────────────────────────────────────────────
[2025-11-01 14:30:15] [INFO] Temperature (BMP280): 24.5°C
[2025-11-01 14:30:15] [INFO] Temperature (DHT22):  24.3°C
[2025-11-01 14:30:15] [INFO] Humidity:             65.2%
[2025-11-01 14:30:15] [INFO] Pressure:             1013.25 hPa
[2025-11-01 14:30:15] [INFO] Altitude:             120.5 m
[2025-11-01 14:30:15] [INFO] ────────────────────────────────────────────────────────────
[2025-11-01 14:30:15] [INFO] Posting to APEX (attempt 1/3)...
[2025-11-01 14:30:16] [INFO] ✓ Successfully posted to APEX: 201
[2025-11-01 14:30:16] [INFO] ✓ Data successfully bridged to APEX
```

### Start the Bridge (apex_to_mqtt)
```powershell
# Navigate to the project root
cd "c:\Users\abara\Documents\Campus work\IFS 325\Greenhouse project\Greenhouse app\Gemini final\sturdy-giggle"

# Run the bridge script (poll APEX and optionally publish to MQTT every 5s)
python enrique_saturday_testing.py --mode apex_to_mqtt --interval 5
```

Configure `APEX_GET_URL` and (optionally) `MQTT_PUBLISH_TOPIC`. This mode logs the latest values it fetches; if MQTT broker connection is configured and reachable, it will also publish the JSON payload to `MQTT_PUBLISH_TOPIC`.

### Stop the Bridge
Press `Ctrl+C` to stop the bridge gracefully.

## Troubleshooting

### Connection Issues

**Problem:** "Connection refused - server unavailable"
- **Solution:** Check that `MQTT_BROKER` and `MQTT_PORT` are correct
- Verify your ESP32 is connected to the same broker
- Test broker connectivity: `telnet your-broker-address 1883`

**Problem:** "Connection refused - bad username or password"
- **Solution:** Set `MQTT_USERNAME` and `MQTT_PASSWORD` if broker requires auth

### No Messages Received

**Problem:** Bridge connects but no messages appear
- **Solution:** 
  1. Verify `MQTT_TOPIC` matches your ESP32's publish topic exactly (case-sensitive)
  2. Check your ESP32 is publishing data (check ESP32 serial monitor)
  3. Test with MQTT client like MQTT Explorer or mosquitto_sub

### APEX POST Failures (mqtt_to_apex)

**Problem:** "Failed to post to APEX"
- **Solution:**
  1. Verify `APEX_POST_URL` is correct and accessible
  2. Test the endpoint with curl or Postman
  3. Check Oracle APEX is running and endpoint is enabled
  4. Review APEX logs for errors

**Problem:** "APEX returned status 500"
- **Solution:** 
  1. Check the APEX PL/SQL handler for errors
  2. Verify payload format matches what APEX expects
  3. Check Oracle APEX session state and privileges

### APEX GET Failures (apex_to_mqtt)

**Problem:** "APEX GET returned status 404/500"
- **Solution:** Verify `APEX_GET_URL` is correct and accessible
- Verify the endpoint supports GET and returns JSON
- If your endpoint returns `{ "items": [...] }`, the script will handle it

**Problem:** "APEX returned no items"
- **Solution:** Ensure your APEX view/table has rows and the REST module returns them

**Problem:** "Failed to parse APEX JSON"
- **Solution:** Inspect the raw response with Postman/curl and adjust the endpoint

### Payload Validation Errors

**Problem:** "Missing required field: X"
- **Solution:** Your ESP32 payload is missing required fields
- Required fields: `timestamp`, `temperature_bmp280`, `temperature_dht22`, `pressure`, `altitude`, `humidity`
- Update your ESP32 code to include all required fields

## Testing

### Test MQTT Connection
```powershell
# Subscribe manually to verify ESP32 is publishing
mosquitto_sub -h your-broker-address -t "greenhouse/sensors" -v
```

### Test APEX Endpoint
```powershell
# Test with curl (PowerShell)
$body = @{
    timestamp = [int][double]::Parse((Get-Date -UFormat %s))
    temperature_bmp280 = 24.5
    temperature_dht22 = 24.3
    pressure = 1013.25
    altitude = 120.5
    humidity = 65.2
} | ConvertTo-Json

Invoke-RestMethod -Uri "YOUR_APEX_URL" -Method Post -Body $body -ContentType "application/json"
```

## Integration with Main Application

This bridge script is **completely independent** of your main Flask application (`python_backend/app.py`). Both can run simultaneously:

1. **Main App** (`app.py`): Serves the Flutter frontend, provides API endpoints, reads from APEX
2. **Bridge** (`enrique_saturday_testing.py`):
  - mqtt_to_apex: Receives live ESP32 data, writes to APEX
  - apex_to_mqtt: Reads from APEX and (optionally) republishes to MQTT

**Running Both:**
```powershell
# Terminal 1: Start main application
cd python_backend
python app.py

# Terminal 2: Start MQTT bridge
cd ..
python enrique_saturday_testing.py
```

## Configuration Options

| Variable | Description | Default |
|----------|-------------|---------|
| `MQTT_BROKER` | MQTT broker hostname/IP | `"broker.hivemq.com"` |
| `MQTT_PORT` | MQTT broker port | `1883` |
| `MQTT_TOPIC` | Topic to subscribe to | `"greenhouse/sensors"` |
| `MQTT_USERNAME` | Broker username (if needed) | `None` |
| `MQTT_PASSWORD` | Broker password (if needed) | `None` |
| `MQTT_CLIENT_ID` | Unique client identifier | `"apex_bridge_client"` |
| `APEX_POST_URL` | Oracle APEX POST endpoint | *Must be configured* |
| `APEX_GET_URL`  | Oracle APEX GET endpoint  | *Must be configured for apex_to_mqtt* |
| `MQTT_PUBLISH_TOPIC` | MQTT topic to publish APEX-fetched readings | `"greenhouse/readings"` |
| `POLL_INTERVAL_SECONDS` | Default polling interval (apex_to_mqtt) | `5` |
| `MAX_RETRIES` | Number of retry attempts | `3` |
| `RETRY_DELAY` | Seconds between retries | `2` |
| `VERBOSE` | Enable detailed logging | `True` |

## Production Deployment

### Run as a Service (Windows)

1. **Using NSSM (Non-Sucking Service Manager):**
```powershell
# Download NSSM from nssm.cc
nssm install MQTTBridge "C:\Python\python.exe" "C:\path\to\enrique_saturday_testing.py"
nssm start MQTTBridge
```

2. **Using Task Scheduler:**
- Create a new task that runs at startup
- Action: Start a program
- Program: `python.exe`
- Arguments: `"C:\path\to\enrique_saturday_testing.py"`
- Check "Run whether user is logged on or not"

### Run as a Background Process (Linux)
```bash
# Using screen
screen -dmS mqtt_bridge python3 enrique_saturday_testing.py

# Using systemd
sudo nano /etc/systemd/system/mqtt-bridge.service
# Add service configuration
sudo systemctl enable mqtt-bridge
sudo systemctl start mqtt-bridge
```

## Security Considerations

1. **MQTT Authentication:** Use username/password authentication on your broker
2. **TLS/SSL:** Consider using MQTT over TLS (port 8883) for encrypted communication
3. **Network Security:** Ensure APEX endpoint is only accessible from trusted IPs
4. **Credentials:** Store sensitive credentials in environment variables:
   ```python
   import os
   MQTT_USERNAME = os.getenv('MQTT_USER')
   MQTT_PASSWORD = os.getenv('MQTT_PASS')
   ```

## Monitoring and Logs

The script logs all activity to the console with timestamps:
- **INFO**: Normal operation (connections, messages received, successful posts)
- **WARNING**: Non-critical issues (validation failures, missing fields)
- **ERROR**: Failures (connection errors, APEX post failures)
- **DEBUG**: Detailed information (raw payloads, responses) - only when VERBOSE=True

To save logs to a file:
```powershell
python enrique_saturday_testing.py > mqtt_bridge.log 2>&1
```

## Support

If you encounter issues:
1. Check this README's Troubleshooting section
2. Verify your configuration matches your setup
3. Test MQTT and APEX connectivity separately
4. Review error messages and logs carefully
5. Ensure your ESP32 payload format matches expectations

## License
Part of the EcoView Greenhouse Monitoring System project.
