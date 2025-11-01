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
    final theme = Theme.of(context);
    final notifications = _notificationManager.notificationHistory;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Alerts',
                style: theme.textTheme.displayMedium?.copyWith(fontSize: 28),
              ),
              const Spacer(),
              if (notifications.isNotEmpty) ...[
                if (notifications.any((notification) => !notification.isRead))
                  OutlinedButton.icon(
                    onPressed: () async {
                      await _notificationManager.markAllAsRead();
                      if (mounted) setState(() {});
                    },
                    icon: const Icon(Icons.done_all),
                    label: const Text('Mark all read'),
                  ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _showClearConfirmation,
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Clear all'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Recent alerts and notifications',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          
          // Notifications List
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You\'ll see alerts here when sensor values exceed thresholds',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _buildNotificationTile(notification, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(AlertNotification notification, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
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
        severityColor = isDark ? Colors.yellow.shade700 : Colors.yellow.shade800;
        severityIcon = Icons.info_outline;
        break;
      default:
        severityColor = Colors.blue;
        severityIcon = Icons.info_outline;
    }

    final dateFormat = DateFormat('MMM d, h:mm a');
    
    // Theme-aware card colors
    final readColor = isDark 
        ? theme.colorScheme.surface.withOpacity(0.5)
        : Colors.grey.shade100;
    final unreadColor = isDark
        ? theme.colorScheme.surface
        : Colors.grey.shade300;
    
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
        color: notification.isRead ? readColor : unreadColor,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: severityColor,
            child: Icon(severityIcon, color: Colors.white),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.message,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${notification.sensorType} • ${dateFormat.format(notification.timestamp)}',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
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