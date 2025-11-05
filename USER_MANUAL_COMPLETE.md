# EcoView Greenhouse Monitoring System User Manual

## Introduction
The EcoView Greenhouse Monitoring System is designed to help greenhouse owners monitor and manage their environmental conditions efficiently. This manual provides a comprehensive guide on how to use the system effectively.

## System Requirements
- **Hardware:**
  - Raspberry Pi with Wi-Fi connectivity
  - Temperature and humidity sensors
  - Light sensors

- **Software:**
  - Python 3.7 or higher
  - Required libraries (e.g., GPIO, Flask)

## Installation Guide
1. Ensure all hardware components are available.
2. Download the software from the repository.
3. Follow the installation instructions provided in the repository's README file.
4. Connect sensors as per the following configuration:
   - Temperature sensor to GPIO pin 4
   - Humidity sensor to GPIO pin 17
   - Light sensor to GPIO pin 27
5. Configure Wi-Fi settings in the configuration file.

## User Interface Overview
The user interface is accessible via a web browser. It includes:
- A dashboard displaying current temperature, humidity, and light levels.
- Alerts and notifications section for abnormal readings.

## Features and Functionality
- **Live Monitoring:** Track real-time data for temperature, humidity, and light.
- **Alerts:** Receive notifications through email or messaging apps when conditions are outside set thresholds.
- **Data Logging:** Historical data can be viewed and exported for analysis.

## Troubleshooting
- **Problem:** Unable to connect to Wi-Fi.
  - **Solution:** Check your Wi-Fi credentials in the configuration file.

- **Problem:** Sensors not reporting data.
  - **Solution:** Ensure sensors are properly connected to the GPIO pins and configured in the software.

## Support and Resources
For further assistance, contact support at support@ecoview.com or visit our website at www.ecoview.com/support.