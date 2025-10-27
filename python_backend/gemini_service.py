"""
Gemini API service for greenhouse monitoring system.
This module provides AI analysis of sensor data using Google's Gemini API.
"""

import os
from datetime import datetime

def get_gemini_analysis(sensor_type, current_value, unit, status, historical_data=None):
    """
    Get AI analysis from Google Gemini API for greenhouse sensor data.
    
    Args:
        sensor_type (str): The type of sensor (temperature, humidity, etc.)
        current_value (float): The current reading from the sensor
        unit (str): The unit of measurement (°C, %, ppm, etc.)
        status (str): The status of the reading (Optimal, Acceptable, Critical, etc.)
        historical_data (list, optional): List of historical readings
        
    Returns:
        str: Analysis text from Gemini API or fallback analysis
    """
    try:
        # Check if API key is available
        api_key = os.environ.get('GEMINI_API_KEY')
        if not api_key:
            return _get_fallback_analysis(sensor_type, current_value, unit, status)
        
        # Import the Gemini API
        try:
            import google.generativeai as genai
        except ImportError:
            return "Gemini API not available. Install the package: pip install google-generativeai"
        
        # Configure the API
        genai.configure(api_key=api_key)
        
        # Create historical data description if available
        historical_context = ""
        if historical_data and len(historical_data) > 0:
            avg = sum(historical_data) / len(historical_data)
            min_val = min(historical_data)
            max_val = max(historical_data)
            trend = "increasing" if historical_data[-1] > historical_data[0] else "decreasing"
            change = abs(historical_data[-1] - historical_data[0]) / max(0.1, historical_data[0]) * 100
            
            historical_context = f"""
            Historical data over 30 days shows an {trend} trend with {change:.1f}% change.
            Average: {avg:.1f}{unit}, Minimum: {min_val:.1f}{unit}, Maximum: {max_val:.1f}{unit}
            """
        
        # Create the prompt
        prompt = f"""
        As a greenhouse management AI assistant, analyze this sensor data:
        
        Sensor: {sensor_type}
        Current Value: {current_value}{unit}
        Current Status: {status}
        Date: {datetime.now().strftime('%Y-%m-%d')}
        {historical_context}
        
        Provide a concise analysis (3-4 sentences) explaining:
        1. What this reading indicates about greenhouse conditions
        2. Potential impacts on plant health and growth
        3. Recommended actions if needed
        
        Your analysis should be factual, practical, and focused on greenhouse management best practices.
        Format the response as plain text without any markdown formatting.
        """
        
        # Call the Gemini API
        model = genai.GenerativeModel('gemini-2.0-flash')
        response = model.generate_content(prompt)
        
        # Return the response text
        if hasattr(response, 'text'):
            return response.text.strip()
        elif hasattr(response, 'candidates') and response.candidates:
            return response.candidates[0].content.parts[0].text.strip()
        else:
            return _get_fallback_analysis(sensor_type, current_value, unit, status)
        
    except Exception as e:
        print(f"Error with Gemini API: {str(e)}")
        return _get_fallback_analysis(sensor_type, current_value, unit, status)

def _get_fallback_analysis(sensor_type, current_value, unit, status):
    """
    Generate fallback analysis when Gemini API is unavailable
    
    Args:
        sensor_type (str): The type of sensor
        current_value (float): The current reading
        unit (str): The unit of measurement
        status (str): The status of the reading
        
    Returns:
        str: Fallback analysis text
    """
    sensor_type = sensor_type.lower()
    
    if sensor_type == 'temperature':
        if status.lower() == 'optimal':
            return f"The current temperature of {current_value}{unit} is within the optimal range for most plants. This promotes healthy photosynthesis and metabolic processes. Maintain current temperature management practices."
        elif status.lower() == 'acceptable':
            return f"The temperature of {current_value}{unit} is acceptable but not ideal. Most plants will continue to grow but may experience slower metabolism. Consider adjusting ventilation or heating to bring temperature closer to optimal range."
        else:
            return f"The temperature of {current_value}{unit} is outside the recommended range. This could stress plants and impact growth. Immediate adjustment to heating or cooling systems is recommended."
    
    elif sensor_type == 'humidity':
        if status.lower() == 'optimal':
            return f"Humidity at {current_value}{unit} provides an ideal environment for transpiration and growth. This level helps prevent both drought stress and fungal diseases. Continue current humidity management."
        elif status.lower() == 'acceptable':
            return f"The humidity level of {current_value}{unit} is acceptable but not ideal. Monitor plants for signs of stress. Consider mild adjustments to humidification or ventilation."
        else:
            return f"Humidity at {current_value}{unit} is concerning. {'High humidity increases disease risk' if float(current_value) > 75 else 'Low humidity may cause drought stress'}. Adjust humidification or ventilation promptly."
    
    elif sensor_type == 'co₂ level' or sensor_type == 'co2 level':
        if float(current_value) < 400:
            return f"CO₂ level of {current_value}{unit} is below atmospheric average, which may limit photosynthesis. This suggests potential air circulation issues. Consider improving ventilation or CO₂ supplementation during daylight hours."
        elif float(current_value) < 800:
            return f"CO₂ at {current_value}{unit} is within normal atmospheric range. Plants can photosynthesize adequately, but growth could be enhanced with supplementation. Consider CO₂ enrichment during peak growing periods for maximum yield."
        elif float(current_value) < 1500:
            return f"CO₂ level of {current_value}{unit} is in the optimal range for enhanced plant growth. This elevated level supports efficient photosynthesis and should promote accelerated development. Maintain current CO₂ management."
        else:
            return f"CO₂ concentration of {current_value}{unit} exceeds optimal range. While not harmful to plants, it provides diminishing returns and may indicate inadequate ventilation. Check air exchange and adjust CO₂ supplementation if needed."
    
    elif sensor_type == 'light':
        return f"Light intensity reading of {current_value}{unit} indicates {'low' if float(current_value) < 4 else 'adequate' if float(current_value) < 8 else 'high'} light conditions. {'Consider supplemental lighting to improve plant growth' if float(current_value) < 4 else 'This level supports healthy photosynthesis for most plants' if float(current_value) < 8 else 'Monitor for heat stress if sustained for long periods'}."
    
    elif sensor_type == 'soil moisture':
        if status.lower() == 'optimal':
            return f"Soil moisture at {current_value}{unit} provides an ideal balance of water and oxygen to roots. This supports healthy nutrient uptake and root development. Continue current irrigation practices."
        elif status.lower() == 'acceptable':
            return f"The soil moisture level of {current_value}{unit} is acceptable but not ideal. {'Consider a slight increase in irrigation frequency' if float(current_value) < 40 else 'Allow growing medium to dry slightly more between waterings'}."
        else:
            return f"Soil moisture at {current_value}{unit} is {'critically low' if float(current_value) < 30 else 'excessively high'}. {'Plants may be experiencing drought stress' if float(current_value) < 30 else 'Root zone may be oxygen-deficient'}. {'Irrigate promptly' if float(current_value) < 30 else 'Improve drainage or reduce watering frequency'}."
    
    elif sensor_type == 'pressure':
        return f"Barometric pressure of {current_value}{unit} is within normal range. Pressure fluctuations have minimal direct impact on plant growth but can signal weather changes. No specific actions needed based on pressure alone."
    
    elif 'flame' in sensor_type.lower():
        if 'detected' in status.lower():
            return "ALERT: Flame or significant infrared source detected. This indicates a potential fire hazard requiring immediate investigation. Check heating equipment and electrical systems immediately."
        else:
            return "No flame detected. Fire risk appears minimal at this time. Continue routine safety monitoring and equipment maintenance."
    
    elif 'gas' in sensor_type.lower() or 'smoke' in sensor_type.lower():
        if status.lower() == 'safe':
            return f"Flammable gas/smoke level of {current_value}{unit} is within safe parameters. No concerning gas accumulation detected. Continue routine safety monitoring."
        elif status.lower() == 'elevated':
            return f"Elevated gas/smoke reading of {current_value}{unit} detected. While not immediately dangerous, this indicates potential issues. Inspect heating equipment, check ventilation systems, and monitor closely."
        else:
            return f"WARNING: High gas/smoke level of {current_value}{unit} detected. This may indicate a significant gas leak or combustion issue. Ventilate the area and inspect all equipment immediately."
    
    elif 'co' in sensor_type.lower() or 'carbon monoxide' in sensor_type.lower():
        if status.lower() == 'safe':
            return f"Carbon monoxide level of {current_value}{unit} is within safe parameters. This indicates proper functioning of combustion equipment. Continue routine safety monitoring."
        elif status.lower() == 'elevated':
            return f"Elevated carbon monoxide reading of {current_value}{unit} detected. While not immediately dangerous, this warrants investigation. Check all combustion equipment and ensure proper ventilation."
        else:
            return f"DANGER: High carbon monoxide level of {current_value}{unit} detected. This presents a serious health hazard and indicates combustion problems. Ventilate immediately and inspect all heating systems."
    
    elif 'air quality' in sensor_type.lower():
        if status.lower() in ['good', 'optimal']:
            return f"Air quality reading of {current_value}{unit} indicates clean air conditions. This provides an optimal environment for plant growth and worker health. Continue current ventilation practices."
        elif status.lower() in ['moderate', 'acceptable']:
            return f"Moderate air quality reading of {current_value}{unit} detected. While not harmful, air purity could be improved. Consider increasing ventilation or adding air filtration."
        else:
            return f"Poor air quality reading of {current_value}{unit} detected. This may affect plant growth and worker health. Improve ventilation, check for contaminant sources, and consider air purification measures."
    
    else:
        # Generic response for other sensor types
        return f"Current {sensor_type} reading is {current_value}{unit}, which is classified as {status}. Continue monitoring for any significant changes that might require attention."


def get_gemini_recommendations(sensor_data):
    """
    Get AI-powered recommendations from Gemini based on current APEX sensor readings.
    Uses fallback logic for speed - only calls Gemini for complex situations.
    
    Args:
        sensor_data (dict): Complete sensor data from APEX including all readings
        
    Returns:
        list: List of recommendation dictionaries with title, description, and type
    """
    # ALWAYS use fast fallback logic with hardcoded thresholds for speed
    # Gemini AI is too slow for real-time recommendations
    return _get_fallback_recommendations(sensor_data)


def _get_fallback_recommendations(sensor_data):
    """
    Generate fast, concise recommendations based on latest APEX data.
    Uses hardcoded thresholds from system specifications.
    
    Thresholds:
    - MQ135 (Air Quality): ≤200 ppm = Good, >500 ppm = Poor
    - MQ2 (Flammable Gas): ≤300 ppm = Safe, >750 ppm = High
    - MQ7 (Carbon Monoxide): ≤300 ppm = Safe, >750 ppm = High
    
    Args:
        sensor_data (dict): Latest APEX sensor data
        
    Returns:
        list: Short, actionable recommendations
    """
    recommendations = []
    
    # Get latest readings from APEX
    avg_temp = (sensor_data.get('temperature_bmp280', 0) + sensor_data.get('temperature_dht22', 0)) / 2
    humidity = sensor_data.get('humidity', 0)
    mq135_drop = sensor_data.get('mq135_drop', 0)  # Air quality
    mq2_drop = sensor_data.get('mq2_drop', 0)      # Flammable gas
    mq7_drop = sensor_data.get('mq7_drop', 0)      # CO
    flame_detected = sensor_data.get('flame_detected', 'No')
    
    # CRITICAL SAFETY ALERTS (using real thresholds)
    if flame_detected == 'Yes':
        recommendations.append({
            "title": "🔥 Flame Detected",
            "description": "Infrared source detected in greenhouse. Immediately inspect all heating equipment, electrical systems, and open flames. Ensure fire extinguisher is accessible.",
            "type": "danger"
        })
    
    if mq7_drop > 750:  # HIGH threshold
        recommendations.append({
            "title": "⚠️ CO High",
            "description": f"Carbon monoxide at {mq7_drop:.0f} ppm exceeds safe levels (>750). Check all combustion equipment and increase ventilation immediately to prevent health hazards.",
            "type": "danger"
        })
    elif mq7_drop > 300:  # ELEVATED threshold
        recommendations.append({
            "title": "CO Elevated",
            "description": f"Carbon monoxide elevated at {mq7_drop:.0f} ppm. Monitor heating equipment closely and ensure proper ventilation is maintained.",
            "type": "warning"
        })
    
    if mq2_drop > 750:  # HIGH threshold
        recommendations.append({
            "title": "⚠️ Flammable Gas High",
            "description": f"Flammable gas detected at {mq2_drop:.0f} ppm (>750 threshold). Inspect for gas leaks, check fuel lines, and increase ventilation to reduce fire risk.",
            "type": "danger"
        })
    elif mq2_drop > 300:  # ELEVATED threshold
        recommendations.append({
            "title": "Gas Levels Elevated",
            "description": f"Flammable gas at {mq2_drop:.0f} ppm. Increase air circulation and monitor levels. Check for any potential leak sources.",
            "type": "warning"
        })
    
    # AIR QUALITY (using real thresholds: 200, 500)
    if mq135_drop > 500:  # POOR threshold
        recommendations.append({
            "title": "Poor Air Quality",
            "description": f"Air quality reading at {mq135_drop:.0f} ppm indicates poor conditions (>500). Increase ventilation to improve air circulation and plant health.",
            "type": "warning"
        })
    elif mq135_drop > 200:  # MODERATE threshold
        recommendations.append({
            "title": "Air Quality Moderate",
            "description": f"Air quality at {mq135_drop:.0f} ppm is acceptable but could be improved. Consider increasing airflow for optimal plant growth conditions.",
            "type": "co2"
        })
    
    # TEMPERATURE (20-27°C optimal for greenhouse plants)
    if avg_temp < 20:
        recommendations.append({
            "title": "Temperature Too Low",
            "description": f"Current temperature is {avg_temp:.1f}°C. Increase heating to reach optimal range of 20-27°C for healthy plant metabolism and growth.",
            "type": "temperature"
        })
    elif avg_temp > 27:
        recommendations.append({
            "title": "Temperature Too High", 
            "description": f"Temperature at {avg_temp:.1f}°C exceeds optimal range. Improve cooling or increase ventilation to prevent heat stress on plants.",
            "type": "temperature"
        })
    
    # HUMIDITY (45-70% optimal)
    if humidity < 45:
        recommendations.append({
            "title": "Humidity Too Dry",
            "description": f"Humidity at {humidity}% is critically low. Too dry - add shading to reduce evaporation. Close vents to retain moisture.",
            "type": "humidity"
        })
    elif humidity > 80:
        recommendations.append({
            "title": "Humidity Critical High",
            "description": f"Humidity at {humidity}% is dangerously high. Risk of fungal growth - run all ventilation and open vents immediately!",
            "type": "humidity"
        })
    elif humidity > 70 and humidity <= 80:
        recommendations.append({
            "title": "Humidity Above Optimal",
            "description": f"Humidity at {humidity}% is above ideal range. Open vents and increase fan speed to improve air circulation.",
            "type": "humidity"
        })
    
    # If everything is good, return positive message
    if not recommendations:
        recommendations.append({
            "title": "✓ All Systems Normal",
            "description": "All sensor readings are within optimal ranges. Greenhouse conditions are ideal for plant growth. Continue monitoring regularly.",
            "type": "info"
        })
    
    # Limit to 5 recommendations max (most critical first)
    return recommendations[:5]