# Greenhouse Sensor Thresholds

This document lists all the thresholds used in the system for sensor status and AI recommendations.

## Temperature (°C)
**Based on optimal greenhouse growing conditions for vegetables and general plants**

- **Optimal**: 20-27°C
- **Acceptable**: 18-20°C or 27-30°C  
- **Critical**: <18°C or >30°C

**Status Logic**: Used in `_get_temperature_status()` in `app.py`
**AI Recommendations**: Triggers alerts if outside 20-27°C range

---

## Humidity (%)
**Based on disease prevention and optimal transpiration rates**

- **Optimal**: 45-70%
- **Acceptable**: 71-80%
- **Critical**: <45% or >80%

**Status Logic**: Used in `_get_humidity_status()` in `app.py`
**AI Recommendations**: 
  - <45%: Too dry - recommend shading to reduce evaporation
  - >80%: Risk of fungal growth - run all ventilation and open vents
  - 45-70%: Optimal range for plant health
**Control Method**: Vents and fans (not humidifiers/dehumidifiers)

---

## MQ135 - Air Quality Sensor (ppm) + CO₂ Combined Status
**From APEX system specifications - measures air quality/CO2-like gases**

### Individual MQ135 Thresholds:
- **Good**: ≤200 ppm
- **Moderate**: >200-500 ppm  
- **Poor**: >500 ppm

### Individual CO₂ Thresholds (calculated from MQ135):
- **Good**: 300-800 ppm
- **Moderate**: 800-1500 ppm
- **High**: >1500 ppm

### Combined Air Quality Status (considers BOTH):
- **Optimal**: MQ135 ≤200 ppm AND CO₂ 300-800 ppm (both sensors perfect)
- **Good**: MQ135 ≤200 ppm OR CO₂ ≤800 ppm (one sensor good)
- **Moderate**: MQ135 200-500 ppm OR CO₂ 800-1500 ppm (one or both moderate)
- **High**: MQ135 >500 ppm OR CO₂ >1500 ppm (one sensor poor)
- **Critical**: BOTH MQ135 >500 ppm AND CO₂ >1500 ppm (both sensors poor)

**Status Logic**: Used in `_get_combined_air_quality_status()` in `app.py`
**AI Recommendations**: Triggers ventilation alerts based on combined status
**Data Source**: `mq135_drop` field from APEX (already calculated, no conversion needed)
**CO₂ Calculation**: `co2_level = 400 + (mq135_drop * 1.2)`
**Note**: Negative values are clamped to 0 (indicates sensor calibration issue)

---
## MQ2 - Flammable Gas Sensor (ppm)
**From APEX system specifications - measures smoke and combustible gases**

- **Safe**: ≤300 ppm
- **Elevated**: 300-750 ppm
- **High**: >750 ppm (DANGER)

**Status Logic**: Used in `build_derived_from_reading()` in `app.py` line 305
**AI Recommendations**: 
  - Warning at >300 ppm: "Increase ventilation"
  - Danger at >750 ppm: "Check for leaks immediately"
**Data Source**: `mq2_drop` field from APEX (already calculated, no conversion needed)
**Note**: Negative values are clamped to 0 (indicates sensor calibration issue)

---

## MQ7 - Carbon Monoxide Sensor (ppm)
**From APEX system specifications - measures CO levels**

- **Safe**: ≤300 ppm
- **Elevated**: 300-750 ppm  
- **High**: >750 ppm (DANGER)

**Status Logic**: Used in `build_derived_from_reading()` in `app.py` line 307
**AI Recommendations**:
  - Warning at >300 ppm: "Monitor heating equipment"  
  - Danger at >750 ppm: "Check heating & ventilation immediately"
**Data Source**: `mq7_drop` field from APEX (already calculated, no conversion needed)
**Note**: Negative values are clamped to 0 (indicates sensor calibration issue)

---

## Light Intensity Sensor (raw ADC value 0-4095)
**Based on ambient light levels for greenhouse monitoring**

- **Dark Night**: 0-300 (no light / remote areas)
- **Low Light**: 301-819 (parks, moonlight, dim streets)
- **Dim Indoor**: 820-1638 (early dusk / dim indoor)
- **Moderate**: 1639-2457 (cloudy day or shaded area)
- **Bright**: 2458+ (good daylight)

**Status Logic**: Used in `_get_light_status()` in `app.py` line 50
**AI Recommendations**: Monitors natural light availability for plant growth
**Data Source**: `light_raw` field from APEX (0-4095 ADC value, no conversion)
**Note**: Values represent raw photoresistor/LDR readings, not lux measurements

---

## Implementation Notes

### Where Thresholds Are Used:

1. **Status Generation** (`app.py`):
   - `_get_temperature_status()` - line 20
   - `_get_humidity_status()` - line 31
   - `build_derived_from_reading()` - lines 303-307 (gas sensors)

2. **AI Recommendations** (`gemini_service.py`):
   - `_get_fallback_recommendations()` - lines 230-295
   - Uses SAME thresholds for consistency

3. **Sensor Analysis** (`gemini_service.py`):
   - `get_gemini_analysis()` - lines 9-85
   - Uses current value + historical data + status

### Data Flow:
```
APEX → readings[0] (latest) → build_derived_from_reading() 
     → apply thresholds → generate status → AI recommendations
```

### Key Principle:
**"ONLY data coming from APEX"** - No conversions, no simulations.
All PPM values come pre-calculated from APEX system.
