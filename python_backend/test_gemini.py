"""
Test script to verify Gemini API is working with real sensor data
"""
import os
import sys

# Add parent directory to path to import gemini_service
sys.path.insert(0, os.path.dirname(__file__))

from gemini_service import get_gemini_analysis

# Test with a realistic sensor reading from APEX
sensor_type = "flammable gas"
current_value = 256.0
unit = "ppm"
status = "Safe"
historical_data = [300.0, 285.0, 270.0, 256.0]  # Decreasing trend

print("=" * 60)
print("TESTING GEMINI API WITH REAL SENSOR DATA")
print("=" * 60)
print(f"\nSensor Type: {sensor_type}")
print(f"Current Value: {current_value} {unit}")
print(f"Status: {status}")
print(f"Historical Data: {historical_data}")
print(f"\nAPI Key Set: {'Yes' if os.environ.get('GEMINI_API_KEY') else 'No'}")
print("\n" + "-" * 60)
print("GEMINI ANALYSIS:")
print("-" * 60)

# Get analysis from Gemini
analysis = get_gemini_analysis(sensor_type, current_value, unit, status, historical_data)

print(analysis)
print("\n" + "=" * 60)
print("TEST COMPLETED")
print("=" * 60)
