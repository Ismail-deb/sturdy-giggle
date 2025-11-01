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
  bool _useFeet = false; // Measurement setting for altitude units

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
    // Load measurement settings
    setState(() {
      _useFeet = prefs.getBool('altitude_use_feet') ?? false;
    });
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
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Settings',
            style: theme.textTheme.displayMedium?.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure your server connection',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          
          // Settings Form
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Measurement Settings
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.straighten,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Measurement Settings',
                                style: theme.textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Altitude units'),
                            subtitle: Text(_useFeet ? 'feet (ft)' : 'meters (m)'),
                            value: _useFeet,
                            onChanged: (val) async {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setBool('altitude_use_feet', val);
                              if (!mounted) return;
                              setState(() {
                                _useFeet = val;
                              });
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text('Altitude units set to: ${val ? 'feet (ft)' : 'meters (m)'}'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.dns,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Server Configuration',
                                style: theme.textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Enter your server IP address to connect to the greenhouse monitoring system.',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _serverIpController,
                            decoration: const InputDecoration(
                              labelText: 'Server IP Address',
                              hintText: 'e.g., 192.168.1.100',
                              prefixIcon: Icon(Icons.computer),
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
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _saveServerIP,
                              icon: _isLoading 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.save),
                              label: Text(_isLoading ? 'Connecting...' : 'Save & Test Connection'),
                            ),
                          ),
                          if (_statusMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                color: _isSuccess 
                                  ? Colors.green.withAlpha((0.1 * 255).round())
                                  : Colors.red.withAlpha((0.1 * 255).round()),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _isSuccess ? Colors.green : Colors.red,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isSuccess ? Icons.check_circle : Icons.error,
                                    color: _isSuccess ? Colors.green : Colors.red,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _statusMessage!,
                                      style: TextStyle(
                                        color: _isSuccess ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Instructions',
                                style: theme.textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '1. Make sure your Flask server is running\n'
                            '2. Enter your computer\'s IP address on the same network\n'
                            '3. Make sure your device and computer are on the same WiFi network\n\n'
                            'Note: You can find your computer\'s IP address by running "ipconfig" in Command Prompt on Windows or "ifconfig" in Terminal on Mac/Linux.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
