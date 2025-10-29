import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _serverIpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _statusMessage;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadSavedIP();
  }

  @override
  void dispose() {
    _serverIpController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedIP() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('server_ip');
    if (ip != null) {
      setState(() {
        _serverIpController.text = ip;
      });
    }
  }

  Future<void> _saveServerIP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final ip = _serverIpController.text.trim();
      await prefs.setString('server_ip', ip);

      // Reinitialize API service with new IP
      ApiService.initialize(customServerIP: ip);

      // Test connection to verify IP works
      final isConnected = await ApiService.checkHealth();
      
      setState(() {
        _isLoading = false;
        _isSuccess = isConnected;
        _statusMessage = isConnected 
            ? 'Successfully connected to server!'
            : 'Failed to connect to server. Please check the IP address.';
      });

      if (isConnected) {
        // Wait a bit so the user sees the success message
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _statusMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Server Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter your server IP address',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _serverIpController,
                decoration: const InputDecoration(
                  labelText: 'Server IP Address',
                  hintText: 'e.g., 192.168.1.100',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an IP address';
                  }
                  
                  // Simple IP address validation
                  final ipRegex = RegExp(
                    r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$'
                  );
                  if (!ipRegex.hasMatch(value)) {
                    return 'Please enter a valid IP address';
                  }
                  
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveServerIP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text('Connect to Server'),
              ),
              if (_statusMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isSuccess ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _statusMessage!,
                    style: TextStyle(
                      color: _isSuccess ? Colors.green[900] : Colors.red[900],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Instructions:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Make sure your Flask server is running\n'
                '2. Enter your computer\'s IP address on the same network\n'
                '3. Make sure your tablet and computer are on the same WiFi network',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'Note: You can find your computer\'s IP address by running "ipconfig" in Command Prompt on Windows or "ifconfig" in Terminal on Mac/Linux.',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}