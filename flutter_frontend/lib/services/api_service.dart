import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:file_saver/file_saver.dart';
import 'server_discovery.dart';

class ApiService {
  static const platform = MethodChannel('com.example.flutter_frontend/downloads');
  static String? _baseUrl;

  /// Initialize the API service with the correct base URL
  static Future<void> initialize({String? customServerIP, bool forceRediscover = false}) async {
    // Allow re-discovery if requested or if not initialized yet
    if (_baseUrl != null && !forceRediscover) {
      debugPrint('API already initialized with: $_baseUrl');
      return;
    }

    debugPrint('🔍 Starting API initialization...');

    if (kIsWeb) {
      // Web platform uses the same origin or specified host
      _baseUrl = 'http://127.0.0.1:5000/api';
      debugPrint('✅ Web platform using: $_baseUrl');
    } else {
      // Try to discover the server first
      debugPrint('📡 Attempting server discovery...');
      debugPrint('📡 Attempting server discovery...');
      String? serverAddress = await ServerDiscovery.discoverServer();
      
      if (serverAddress != null) {
        // serverAddress already includes port (e.g., "192.168.207.51:5000")
        // Check if port is already included
        if (serverAddress.contains(':')) {
          _baseUrl = 'http://$serverAddress/api';
        } else {
          _baseUrl = 'http://$serverAddress:5000/api';
        }
        debugPrint('✅ Discovered server at: $_baseUrl');
      } else if (customServerIP != null) {
        // Use custom IP if provided
        // Check if port is already included
        if (customServerIP.contains(':')) {
          _baseUrl = 'http://$customServerIP/api';
        } else {
          _baseUrl = 'http://$customServerIP:5000/api';
        }
        debugPrint('✅ Using custom server IP: $_baseUrl');
      } else if (Platform.isAndroid) {
        // Android fallback - will be replaced by discovered IP
        _baseUrl = 'http://192.168.18.226:5000/api';
        debugPrint('⚠️  Using fallback Android IP (discovery failed): $_baseUrl');
      } else if (Platform.isIOS) {
        // iOS fallback
        _baseUrl = 'http://localhost:5000/api';
      } else {
        // Desktop platforms fallback
        _baseUrl = 'http://localhost:5000/api';
      }
    }

    debugPrint('ApiService initialized with base URL: $_baseUrl');
  }

  /// Override the base URL (useful for testing or production)
  static void setBaseUrl(String url) {
    _baseUrl = url;
    debugPrint('ApiService base URL set to: $_baseUrl');
  }
  
  /// Get the current base URL
  static Future<String> getBaseUrl() async {
    await _ensureInitialized();
    return _baseUrl!;
  }
  
  /// Update the server IP address (keeping the same port and path)
  static Future<void> updateServerIp(String ipAddress) async {
    await _ensureInitialized();
    final Uri currentUri = Uri.parse(_baseUrl!);
    final newUrl = 'http://$ipAddress:${currentUri.port}/api';
    _baseUrl = newUrl;
    debugPrint('ApiService IP updated to: $_baseUrl');
  }

  /// Get all items from the API
  static Future<List<dynamic>> getItems() async {
    await _ensureInitialized();
    
    try {
      final response = await http.get(Uri.parse('$_baseUrl/items'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load items: ${response.statusCode}');
      }
      } catch (e) {
      debugPrint('Error fetching items: $e');
      rethrow;
    }
  }

  /// Get a single item by ID
  static Future<Map<String, dynamic>> getItem(int id) async {
    await _ensureInitialized();
    
    try {
      final response = await http.get(Uri.parse('$_baseUrl/items/$id'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load item $id: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching item $id: $e');
      rethrow;
    }
  }

  /// Create a new item
  static Future<Map<String, dynamic>> createItem(Map<String, dynamic> item) async {
    await _ensureInitialized();
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/items'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(item),
      );
      
      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create item: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error creating item: $e');
      rethrow;
    }
  }

  /// Check API health
  static Future<bool> checkHealth() async {
    await _ensureInitialized();
    
    try {
      debugPrint('Checking API health at: $_baseUrl/health');
      final response = await http.get(Uri.parse('$_baseUrl/health'));
      debugPrint('Health check response: ${response.statusCode} ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Health check failed: $e');
      return false;
    }
  }
  
  /// Get greenhouse sensor data
  static Future<Map<String, dynamic>> getSensorData() async {
    await _ensureInitialized();
    
    try {
  final response = await http.get(Uri.parse('$_baseUrl/sensor-data'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load sensor data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching sensor data: $e');
      rethrow;
    }
  }
  
  /// Get AI recommendations based on current sensor data
  static Future<Map<String, dynamic>> getAIRecommendations() async {
    await _ensureInitialized();
    
    try {
      final response = await http.get(Uri.parse('$_baseUrl/ai-recommendations'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load AI recommendations: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching AI recommendations: $e');
      rethrow;
    }
  }
  
  /// Get alerts from the API
  static Future<List<dynamic>> getAlerts() async {
    await _ensureInitialized();
    
    try {
      final response = await http.get(Uri.parse('$_baseUrl/alerts'));
      
      if (response.statusCode == 200) {
        // Handle both formats: direct list or object with alerts property
        final decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded;
        } else if (decoded is Map && decoded.containsKey('alerts')) {
          return decoded['alerts'] as List<dynamic>;
        } else {
          debugPrint('Unexpected alerts response format: $decoded');
          return [];
        }
      } else {
        throw Exception('Failed to load alerts: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching alerts: $e');
      rethrow;
    }
  }

  /// Export greenhouse report as PDF.
  /// - Web: opens the report in a new tab (browser handles download).
  /// - Desktop (Windows/macOS/Linux): prompts for a location using a Save As dialog.
  /// - Mobile: saves to app documents/Downloads and returns the saved path.
  static Future<String> exportReport({String? suggestedName}) async {
    await _ensureInitialized();

    final url = Uri.parse('$_baseUrl/export-report');
    final String filename = suggestedName ??
        'EcoView_Report_${DateTime.now().toIso8601String().replaceAll(':', '-')}.pdf';

    if (kIsWeb) {
      // For web, just open the link in a new tab and let the browser handle it
      html.window.open(url.toString(), '_blank');
      return 'opened-in-browser';
    }

    // Native platforms: fetch bytes
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Failed to export report: HTTP ${res.statusCode}');
    }

    // Desktop: show Save As dialog via file_saver
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final savedPath = await FileSaver.instance.saveFile(
        name: filename.replaceAll('.pdf', ''),
        bytes: res.bodyBytes,
        ext: 'pdf',
        mimeType: MimeType.pdf,
      );
      // savedPath may be empty on cancel
      return savedPath.toString();
    }

    // Mobile: Save to Downloads folder using native Android MediaStore
    if (Platform.isAndroid || Platform.isIOS) {
      debugPrint('📱 Saving PDF to Downloads folder...');
      debugPrint('   File size: ${res.bodyBytes.length} bytes');
      debugPrint('   Filename: $filename');
      
      try {
        if (Platform.isAndroid) {
          // Use native Android channel to save to Downloads folder properly
          debugPrint('   Using MediaStore API for Android 14...');
          
          final String result = await platform.invokeMethod('saveToDownloads', {
            'filename': filename,
            'bytes': res.bodyBytes,
          });
          
          debugPrint('✅ PDF SAVED TO DOWNLOADS FOLDER!');
          debugPrint('   📁 File: $filename');
          debugPrint('   🎉 Open My Files → Downloads or Recent to find it!');
          debugPrint('   Result: $result');
          
          return result;
        } else {
          // For iOS - use FileSaver
          String nameWithoutExt = filename;
          if (nameWithoutExt.toLowerCase().endsWith('.pdf')) {
            nameWithoutExt = nameWithoutExt.substring(0, nameWithoutExt.length - 4);
          }
          
          final String savedPath = await FileSaver.instance.saveFile(
            name: nameWithoutExt,
            bytes: res.bodyBytes,
            ext: 'pdf',
            mimeType: MimeType.pdf,
          );
          
          debugPrint('✅ PDF saved to iOS: $savedPath');
          return savedPath;
        }
      } catch (e, stackTrace) {
        debugPrint('❌ Save failed: $e');
        debugPrint('   Stack trace: $stackTrace');
        rethrow;
      }
    }
    
    // Fallback for any other platform
    final Directory baseDir = await getApplicationDocumentsDirectory();
    final String path = '${baseDir.path}/$filename';
    final file = File(path);
    await file.writeAsBytes(res.bodyBytes);
    debugPrint('✅ PDF saved: $path');
    return path;
  }
  
  /// Get detailed sensor analysis with AI insights for a specific sensor type
  static Future<Map<String, dynamic>> getSensorAnalysis(
    String sensorType, 
    {String timeRange = 'hours', bool includeAI = true}
  ) async {
    await _ensureInitialized();
    
    // Convert sensor type to expected backend format
    final String apiSensorType = sensorType.toLowerCase()
        .replaceAll('₂', '2')  // Replace subscript with normal character
        .replaceAll(' level', '') // Remove 'level' suffix if present
        .replaceAll(' and ', '_&_') // Standardize conjunction format
        .replaceAll(' & ', '_&_'); // Standardize conjunction format
    
  // Debug output
  debugPrint('Requesting sensor analysis for: $sensorType (API format: $apiSensorType, includeAI: $includeAI)');
    
    try {
    final response = await http.get(
      Uri.parse('$_baseUrl/sensor-analysis/$apiSensorType?time_range=$timeRange&include_ai=$includeAI'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('Failed to load sensor analysis: ${response.statusCode}, Response: ${response.body}');
        throw Exception('Failed to load sensor analysis: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching sensor analysis for $sensorType: $e');
      rethrow;
    }
  }

  /// Get AI analysis only for a sensor (async loading)
  static Future<Map<String, dynamic>> getSensorAIAnalysis(String sensorType) async {
    await _ensureInitialized();
    
    // Convert sensor type to expected backend format
    final String apiSensorType = sensorType.toLowerCase()
        .replaceAll('₂', '2')
        .replaceAll(' level', '')
        .replaceAll(' and ', '_&_')
        .replaceAll(' & ', '_&_');
    
    debugPrint('Requesting AI analysis for: $sensorType (API format: $apiSensorType)');
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/sensor-analysis/$apiSensorType/ai')
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('Failed to load AI analysis: ${response.statusCode}, Response: ${response.body}');
        throw Exception('Failed to load AI analysis: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching AI analysis for $sensorType: $e');
      rethrow;
    }
  }

  /// Get thresholds from backend
  static Future<Map<String, dynamic>?> getThresholds() async {
    await _ensureInitialized();
    
    try {
      final response = await http.get(Uri.parse('$_baseUrl/thresholds'));
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['thresholds'] as Map<String, dynamic>;
      } else {
        debugPrint('Failed to load thresholds: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching thresholds: $e');
      return null;
    }
  }

  /// Update thresholds on backend
  static Future<bool> updateThresholds(Map<String, dynamic> thresholds) async {
    await _ensureInitialized();
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/thresholds'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(thresholds),
      );
      
      if (response.statusCode == 200) {
        debugPrint('Thresholds updated successfully');
        return true;
      } else {
        debugPrint('Failed to update thresholds: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating thresholds: $e');
      return false;
    }
  }

  // Private helper to ensure the service is initialized
  static Future<void> _ensureInitialized() async {
    if (_baseUrl == null) {
      await initialize();
    }
  }
}