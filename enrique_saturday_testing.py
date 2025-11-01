#!/usr/bin/env python3
"""
APEX Pull-Only Testing Script
=============================
This standalone utility polls an Oracle APEX REST GET endpoint for the
latest greenhouse readings at a fixed interval and logs them to the console.

Notes:
- No MQTT subscription/publish. This script reads from APEX only.
- It validates the payload shape and prints key values for quick checks.
"""

import json
import time
import requests
from datetime import datetime
from typing import Dict, Any, Optional
import sys
import argparse

# ============================================================================
# CONFIGURATION - Update these values for your setup
# ============================================================================

"""Configuration - Update these values for your setup"""

# Oracle APEX GET Endpoint (can be ORDS module or REST-enabled table)
APEX_GET_URL = "https://oracleapex.com/ords/at2/greenhouse/sensor"  # Replace with your APEX GET endpoint

# APEX polling configuration
POLL_INTERVAL_SECONDS = 5
APEX_GET_TIMEOUT = 10
APEX_SELECT_LATEST_ONLY = True  # If APEX returns multiple rows, pick the newest by timestamp
APEX_LIMIT = 50  # Try to limit results where supported (ORDS AutoREST supports limit/offset)
APEX_APPEND_SLASH_FALLBACK = True  # If first GET fails, retry with a trailing '/'

# Optional headers/auth if your APEX module requires them
APEX_HEADERS = {
    "Accept": "application/json"
}
APEX_AUTH = None  # e.g., ("user", "password") if Basic Auth is enabled
APEX_VERIFY_SSL = True  # Set to False only for troubleshooting cert errors
APEX_SEND_PARAMS = True  # Disable to avoid sending limit/offset during troubleshooting

# Retry Configuration
MAX_RETRIES = 3
RETRY_DELAY = 2  # seconds

# Logging
VERBOSE = True  # Set to False to reduce console output

# Default mode (set via CLI too): "apex_to_mqtt" or "mqtt_to_apex"
DEFAULT_MODE = "apex_to_mqtt"

# ============================================================================
# Helper Functions
# ============================================================================

def log(message: str, level: str = "INFO"):
    """Print timestamped log messages"""
    if VERBOSE or level == "ERROR":
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        print(f"[{timestamp}] [{level}] {message}")


def validate_sensor_payload(payload: Dict[str, Any]) -> bool:
    """
    Validate that the payload contains expected sensor fields.
    Returns True if valid, False otherwise.
    """
    required_fields = [
        'timestamp',
        'temperature_bmp280',
        'temperature_dht22',
        'pressure',
        'altitude',
        'humidity'
    ]
    
    for field in required_fields:
        if field not in payload:
            log(f"Missing required field: {field}", "WARNING")
            return False
    
    return True


def normalize_apex_record(rec: Dict[str, Any]) -> Dict[str, Any]:
    """
    Normalize a single APEX record to the app's expected keys/types:
    - Lower-case keys (ORDS may emit UPPERCASE)
    - Derive numeric 'timestamp' from 'timestamp_reading' ISO string
    """
    # Lowercase keys to be resilient to ORDS case
    lowered = { (k.lower() if isinstance(k, str) else k): v for k, v in rec.items() }

    # Derive numeric timestamp if missing
    if 'timestamp' not in lowered:
        ts_str = lowered.get('timestamp_reading') or lowered.get('timestamp_iso')
        if isinstance(ts_str, str) and ts_str:
            try:
                # Support formats: 2025-10-29T15:21:22.971802Z or without microseconds
                ts_clean = ts_str.rstrip('Z')
                from datetime import datetime as _dt
                try:
                    dt = _dt.strptime(ts_clean, "%Y-%m-%dT%H:%M:%S.%f")
                except ValueError:
                    dt = _dt.strptime(ts_clean, "%Y-%m-%dT%H:%M:%S")
                lowered['timestamp'] = dt.timestamp()
            except Exception:
                # Leave missing if parse fails; validator will flag
                pass

    return lowered

def fetch_from_apex() -> Optional[Dict[str, Any]]:
    """
    Fetch sensor data from Oracle APEX via GET endpoint.
    Tries to handle common APEX response shapes:
      - Single JSON object with fields
      - List/array of objects
      - Object with an 'items' list (ORDS auto-REST often uses this)

    Returns the best-guess latest record (dict) or None on failure.
    """
    try:
        params = None
        if APEX_SEND_PARAMS:
            params = {
                # ORDS AutoREST commonly supports limit/offset
                "limit": APEX_LIMIT,
                "offset": 0,
            }

        def _do_get(url: str):
            return requests.get(
                url,
                params=params,
                headers=APEX_HEADERS,
                auth=APEX_AUTH,
                timeout=APEX_GET_TIMEOUT,
                verify=APEX_VERIFY_SSL,
                allow_redirects=True,
            )

        resp = _do_get(APEX_GET_URL)

        # Fallback: retry with a trailing slash if non-200 and no trailing slash
        if resp.status_code != 200 and APEX_APPEND_SLASH_FALLBACK and not APEX_GET_URL.endswith('/'):
            alt_url = APEX_GET_URL + '/'
            log(f"Retrying with trailing slash: {alt_url}", "WARNING")
            resp = _do_get(alt_url)

        if resp.status_code != 200:
            ctype = resp.headers.get('Content-Type')
            snippet = resp.text[:300] if resp.text else ''
            log(f"✗ APEX GET returned status {resp.status_code}", "ERROR")
            if ctype:
                log(f"Content-Type: {ctype}", "ERROR")
            if snippet:
                log(f"Body (first 300 chars): {snippet}", "ERROR")
            return None

        ctype = resp.headers.get('Content-Type', '')
        if 'application/json' not in ctype.lower():
            log(f"✗ Unexpected content type: {ctype}", "ERROR")
            log(f"Body (first 300 chars): {resp.text[:300]}", "ERROR")
            return None

        try:
            data = resp.json()
        except ValueError as e:
            log(f"✗ Failed to parse JSON: {e}", "ERROR")
            log(f"Body (first 300 chars): {resp.text[:300]}", "ERROR")
            return None

        # Case 1: Direct object
        if isinstance(data, dict):
            # ORDS often returns {"items": [...]} for collections
            if "items" in data and isinstance(data["items"], list):
                items = data["items"]
            else:
                # Single record
                candidate = data
                candidate = normalize_apex_record(candidate)
                return candidate if validate_sensor_payload(candidate) else None
        elif isinstance(data, list):
            items = data
        else:
            log("✗ Unexpected APEX response format", "ERROR")
            return None

        if not items:
            log("✗ APEX returned no items", "WARNING")
            return None

        # Normalize items and, if multiple, choose latest by derived 'timestamp' when available
        norm_items = []
        for it in items:
            if isinstance(it, dict):
                norm_items.append(normalize_apex_record(it))

        if not norm_items:
            log("✗ APEX returned items but none were objects", "ERROR")
            return None

        candidate = None
        if APEX_SELECT_LATEST_ONLY:
            try:
                candidate = max(norm_items, key=lambda x: x.get("timestamp", 0))
            except Exception:
                # Fallback to last element
                candidate = norm_items[-1]
        else:
            candidate = norm_items[-1]

        if not isinstance(candidate, dict):
            log("✗ APEX item is not an object", "ERROR")
            return None

        if not validate_sensor_payload(candidate):
            log("✗ APEX item failed validation", "WARNING")
            try:
                keys = ", ".join(candidate.keys())
                log(f"Available keys: {keys}", "WARNING")
            except Exception:
                pass
            return None

        return candidate

    except requests.exceptions.ConnectTimeout:
        log("✗ APEX GET connection timed out (unable to connect)", "ERROR")
    except requests.exceptions.ReadTimeout:
        log("✗ APEX GET read timed out (server didn't respond in time)", "ERROR")
    except requests.exceptions.ConnectionError as e:
        log(f"✗ APEX connection error: {e}", "ERROR")
    except ValueError as e:
        log(f"✗ Failed to parse APEX JSON: {e}", "ERROR")
    except Exception as e:
        log(f"✗ Unexpected error fetching from APEX: {e}", "ERROR")
    return None


def probe_connectivity(url: str, timeout: int = 5):
    """Quick diagnostics: DNS resolution and TCP connect test to url's host:443."""
    try:
        from urllib.parse import urlparse
        import socket
        p = urlparse(url)
        host = p.hostname
        if not host:
            log("Probe: invalid URL hostname", "ERROR")
            return
        log(f"Probe: resolving {host}...", "INFO")
        try:
            infos = socket.getaddrinfo(host, 443, type=socket.SOCK_STREAM)
        except Exception as e:
            log(f"Probe: DNS resolution failed: {e}", "ERROR")
            return
        addrs = list({ (ai[4][0], ai[0] == socket.AF_INET6) for ai in infos })
        for addr, is_v6 in addrs:
            fam = "IPv6" if is_v6 else "IPv4"
            log(f"Probe: attempting TCP connect to {addr}:443 ({fam})", "INFO")
            s = None
            try:
                s = socket.create_connection((addr, 443), timeout=timeout)
                log("Probe: TCP connect OK", "INFO")
            except Exception as e:
                log(f"Probe: TCP connect failed: {e}", "ERROR")
            finally:
                try:
                    if s:
                        s.close()
                except:
                    pass
    except Exception as e:
        log(f"Probe: unexpected error: {e}", "ERROR")


# ============================================================================
# Main Execution
# ============================================================================

def main():
    """Main function to run the bridge in the selected mode"""
    global APEX_GET_URL, APEX_GET_TIMEOUT, APEX_VERIFY_SSL, APEX_AUTH, VERBOSE

    parser = argparse.ArgumentParser(description="APEX Pull-Only Testing Script")
    parser.add_argument("--interval", type=int, default=POLL_INTERVAL_SECONDS,
                        help="Polling interval (seconds) for APEX GET")
    parser.add_argument("--timeout", type=int, default=APEX_GET_TIMEOUT,
                        help="HTTP timeout (seconds) for APEX GET")
    parser.add_argument("--url", type=str, default=APEX_GET_URL,
                        help="Override APEX GET URL (useful for testing)")
    parser.add_argument("--insecure", action="store_true",
                        help="Disable TLS verification (testing only)")
    parser.add_argument("--basic-auth", type=str, default=None,
                        help="Basic auth in the form user:password (if endpoint requires it)")
    parser.add_argument("--verbose", action="store_true", help="Enable verbose logging")
    parser.add_argument("--raw", action="store_true", help="Print raw JSON of the selected record")
    parser.add_argument("--once", action="store_true", help="Fetch once and exit (diagnostics mode)")
    parser.add_argument("--probe", action="store_true", help="Run DNS/TCP connectivity probe before fetching")
    parser.add_argument("--no-params", action="store_true", help="Do not send limit/offset params to APEX")
    args = parser.parse_args()

    if args.verbose:
        VERBOSE = True

    # Apply CLI overrides
    global APEX_SEND_PARAMS
    APEX_GET_URL = args.url or APEX_GET_URL
    APEX_GET_TIMEOUT = max(1, int(args.timeout))
    APEX_VERIFY_SSL = not args.insecure
    APEX_SEND_PARAMS = not args.no_params
    if args.basic_auth:
        if ":" in args.basic_auth:
            user, pwd = args.basic_auth.split(":", 1)
            APEX_AUTH = (user, pwd)
        else:
            log("--basic-auth must be in the form user:password; ignoring.", "WARNING")

    print("=" * 70)
    print("  APEX Pull-Only Testing Script")
    print("=" * 70)
    print()

    # Validate configuration for GET mode
    if APEX_GET_URL.startswith("https://your-apex-url.com"):
        log("✗ ERROR: Please update APEX_GET_URL with your actual endpoint", "ERROR")
        log("   Edit the CONFIGURATION section at the top of this script", "ERROR")
        sys.exit(1)

    log(f"APEX GET URL:  {APEX_GET_URL}", "INFO")
    log(f"Polling every: {args.interval}s", "INFO")
    log(f"HTTP timeout:  {APEX_GET_TIMEOUT}s", "INFO")
    if APEX_AUTH:
        log("Auth:          Basic (provided)", "INFO")
    log(f"TLS verify:    {APEX_VERIFY_SSL}", "INFO")
    log(f"Send params:   {APEX_SEND_PARAMS}", "INFO")
    log("", "INFO")

    try:
        def _print_record(record: Dict[str, Any] | None):
            if record:
                log("─" * 60, "INFO")
                log("Fetched latest reading from APEX:", "INFO")
                log(f"Timestamp:           {record.get('timestamp')}", "INFO")
                log(f"Temperature (BMP280): {record.get('temperature_bmp280')}°C", "INFO")
                log(f"Temperature (DHT22):  {record.get('temperature_dht22')}°C", "INFO")
                log(f"Humidity:             {record.get('humidity')}%", "INFO")
                log(f"Pressure:             {record.get('pressure')} hPa", "INFO")
                log(f"Altitude:             {record.get('altitude')} m", "INFO")
                log(f"Light:                {record.get('light_raw', 'N/A')}", "INFO")
                log(f"MQ135 (Air Quality):  {record.get('mq135_drop', 'N/A')} ppm", "INFO")
                log(f"MQ2 (Flammable Gas):  {record.get('mq2_drop', 'N/A')} ppm", "INFO")
                log(f"MQ7 (CO):             {record.get('mq7_drop', 'N/A')} ppm", "INFO")
                if args.raw:
                    try:
                        pretty = json.dumps(record, indent=2)
                        log("Raw selected JSON:", "INFO")
                        print(pretty)
                    except Exception:
                        pass
                log("─" * 60, "INFO")

        if args.probe:
            probe_connectivity(APEX_GET_URL, timeout=5)

        if args.once:
            rec = fetch_from_apex()
            _print_record(rec)
            return

        while True:
            rec = fetch_from_apex()
            _print_record(rec)
            time.sleep(max(1, int(args.interval)))

    except KeyboardInterrupt:
        log("", "INFO")
        log("✓ Shutting down gracefully...", "INFO")


if __name__ == "__main__":
    main()
