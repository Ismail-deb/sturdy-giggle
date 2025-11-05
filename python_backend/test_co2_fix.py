"""Test CO2 level extraction for air_quality sensor type"""
import os
from dotenv import load_dotenv
load_dotenv()

from app import build_derived_from_reading

# Test with sample reading
test_reading = {'mq135_drop': 250}
result = build_derived_from_reading(test_reading)

print("="*60)
print("Testing CO2 Level Calculation")
print("="*60)
print(f"Input MQ135 Drop: {test_reading['mq135_drop']} ppm")
print(f"Calculated CO2 Level: {result.get('co2_level')} ppm")
print(f"Expected: {400 + 250 * 1.2} ppm")
print("="*60)

# Test if co2_level is properly extracted
if result.get('co2_level') == 400 + 250 * 1.2:
    print("✅ CO2 calculation is correct!")
else:
    print(f"❌ CO2 calculation is wrong. Expected: {400 + 250 * 1.2}, Got: {result.get('co2_level')}")
