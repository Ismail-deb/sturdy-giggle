import 'package:flutter/material.dart';
import '../models/alert_notification.dart';
import '../services/notification_manager.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationManager _notificationManager = NotificationManager();
  
  @override
  Widget build(BuildContext context) {
    // Filter to show only unread notifications, or all if showing history
    final notifications = _notificationManager.notificationHistory;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _showClearConfirmation,
              tooltip: 'Clear all notifications',
            ),
          if (notifications.any((notification) => !notification.isRead))
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: () async {
                await _notificationManager.markAllAsRead();
                if (mounted) setState(() {});
              },
              tooltip: 'Mark all as read',
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationTile(notification, index);
              },
            ),
    );
  }

  Widget _buildNotificationTile(AlertNotification notification, int index) {
    Color severityColor;
    IconData severityIcon;
    
    switch (notification.severity.toLowerCase()) {
      case 'critical':
        severityColor = Colors.red;
        severityIcon = Icons.warning_amber_rounded;
        break;
      case 'high':
        severityColor = Colors.orange;
        severityIcon = Icons.warning_rounded;
        break;
      case 'medium':
        severityColor = Colors.yellow.shade800;
        severityIcon = Icons.info_outline;
        break;
      default:
        severityColor = Colors.blue;
        severityIcon = Icons.info_outline;
    }

    final dateFormat = DateFormat('MMM d, h:mm a');
    
    return Dismissible(
      key: ValueKey('${notification.id}_$index'), // Unique key combining ID and index
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        // Remove the notification from the list
        await _notificationManager.removeNotification(notification.id);
        if (mounted) {
          setState(() {});
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: notification.isRead ? Colors.grey.shade100 : Colors.grey.shade300,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: severityColor,
            child: Icon(severityIcon, color: Colors.white),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(notification.message),
              const SizedBox(height: 4),
              Text(
                '${notification.sensorType} • ${dateFormat.format(notification.timestamp)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          isThreeLine: true,
          onTap: () {
            _notificationManager.markAsRead(notification.id);
            setState(() {});
          },
        ),
      ),
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to clear all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              _notificationManager.clearHistory();
              setState(() {});
              Navigator.of(context).pop();
            },
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );
  }
}