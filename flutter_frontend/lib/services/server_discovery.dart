import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServerDiscovery {
  static const int port = 45678;
  static const String serverPrefix = "GREENHOUSE_SERVER:";
  
  static Future<String?> discoverServer() async {
    try {
      // First check if we have a stored server address that's working
      final prefs = await SharedPreferences.getInstance();
      final storedIp = prefs.getString('server_ip');
      
      if (storedIp != null) {
        // Test if the stored IP works
        try {
          final httpClient = HttpClient();
          httpClient.connectionTimeout = const Duration(seconds: 2);
          final request = await httpClient.getUrl(
            Uri.parse('http://$storedIp/api/health')
          );
          final response = await request.close();
          
          if (response.statusCode == 200) {
            debugPrint('Using stored server IP: $storedIp');
            return storedIp;
          }
        } catch (e) {
          debugPrint('Stored server IP is not responding: $e');
        }
      }
      
      // If no stored IP or stored IP doesn't work, try discovery
      debugPrint('Starting server discovery...');
      
      if (kIsWeb) {
        // Web doesn't support UDP sockets, fallback to localhost
        return 'localhost:5000';
      }
      
      // Create UDP socket for discovery
      final socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4, 
        port
      );
      
      // Set timeout for discovery
      final completer = Completer<String?>();
      
      // Create a timer to handle discovery timeout
      Timer? timer = Timer(const Duration(seconds: 15), () {
        if (!completer.isCompleted) {
          completer.complete(null);
          socket.close();
        }
      });
      
      // Listen for server broadcasts
      socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? datagram = socket.receive();
          if (datagram != null) {
            String message = String.fromCharCodes(datagram.data);
            debugPrint('Received broadcast: $message');
            
            if (message.startsWith(serverPrefix)) {
              String serverInfo = message.substring(serverPrefix.length);
              debugPrint('Server info: $serverInfo');
              
              // Save the discovered IP for future use
              prefs.setString('server_ip', serverInfo);
              
              if (!completer.isCompleted) {
                completer.complete(serverInfo);
                timer.cancel();
                socket.close();
              }
            }
          }
        }
      });
      
      // Wait for discovery or timeout
      return completer.future;
    } catch (e) {
      debugPrint('Error in server discovery: $e');
      return null;
    }
  }
}