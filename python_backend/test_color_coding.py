"""
Test script to verify color coding functionality in app.py
"""
import sys
import os

# Add the parent directory to the path so we can import from app.py
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import _get_status_with_color, build_derived_from_reading

def test_status_color_coding():
    """Test that _get_status_with_color returns correct colors for various statuses"""
    
    print("Testing Color Coding System")
    print("=" * 60)
    
    test_cases = [
        # (status_text, expected_severity)
        ("Optimal", "optimal"),
        ("Good", "optimal"),
        ("Acceptable", "warning"),
        ("Moderate", "warning"),
        ("Critical", "critical"),
        ("High", "critical"),
        ("Poor", "critical"),
        ("Unknown", "unknown"),
        ("Dark Night", "unknown"),  # Light status
        ("Bright", "optimal"),  # Light status
    ]
    
    for status, expected_severity in test_cases:
        status_text, color, severity = _get_status_with_color(status)
        print(f"\nStatus: {status:20s} → Severity: {severity:10s} Color: {color}")
        assert severity == expected_severity, f"Expected {expected_severity} but got {severity} for {status}"
    
    print("\n" + "=" * 60)
    print("✅ All color coding tests passed!")

def test_derived_fields():
    """Test that build_derived_from_reading includes color fields"""
    
    print("\n\nTesting Derived Fields with Color Coding")
    print("=" * 60)
    
    # Mock APEX reading
    mock_reading = {
        "temperature_bmp280": 23.5,
        "temperature_dht22": 24.0,
        "humidity": 55.0,
        "moisture": 50,
        "light_raw": 2000,
        "mq135_drop": 150,
        "mq2_drop": 250,
        "mq7_drop": 200,
        "mq135_baseline": 400,
        "mq2_baseline": 500,
        "mq7_baseline": 300,
        "flame_raw": 4000,
        "flame_detected": 0,
        "pressure": 1013.25,
        "altitude": 100.0,
        "timestamp": 1234567890
    }
    
    derived = build_derived_from_reading(mock_reading)
    
    # Check that color coding fields exist
    color_fields = [
        ("temperature", "temperature_status", "temperature_color", "temperature_severity"),
        ("humidity", "humidity_status", "humidity_color", "humidity_severity"),
        ("soil_moisture", "soil_moisture_status", "soil_moisture_color", "soil_moisture_severity"),
        ("light", "light_status", "light_color", "light_severity"),
        ("air_quality", "air_quality", "air_quality_color", "air_quality_severity"),  # air_quality is both value and status
    ]
    
    print("\nDerived Fields with Color Coding:")
    for base_field, status_field, color_field, severity_field in color_fields:
        if base_field in derived:
            value = derived.get(base_field)
            status = derived.get(status_field, "N/A")
            color = derived.get(color_field, "N/A")
            severity = derived.get(severity_field, "N/A")
            
            print(f"\n{base_field.upper()}")
            print(f"  Value:    {value}")
            print(f"  Status:   {status}")
            print(f"  Color:    {color}")
            print(f"  Severity: {severity}")
            
            # Verify fields exist
            assert status_field in derived, f"Missing {status_field}"
            assert color_field in derived, f"Missing {color_field}"
            assert severity_field in derived, f"Missing {severity_field}"
    
    print("\n" + "=" * 60)
    print("✅ All derived field tests passed!")
    print("\n📊 Sample API Response Structure:")
    print("   {")
    print(f'     "temperature": {derived["temperature"]},')
    print(f'     "temperature_status": "{derived["temperature_status"]}",')
    print(f'     "temperature_color": "{derived["temperature_color"]}",')
    print(f'     "temperature_severity": "{derived["temperature_severity"]}",')
    print("     ...")
    print("   }")

if __name__ == "__main__":
    test_status_color_coding()
    test_derived_fields()
    print("\n✨ All tests completed successfully!")
