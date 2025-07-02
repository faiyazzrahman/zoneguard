import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../services/supabase_service.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> with SingleTickerProviderStateMixin {
  int _currentIndex = 3;
  late TabController _tabController;
  
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _crimeAlerts = [];
  List<Map<String, dynamic>> _communityUpdates = [];
  bool _isLoading = true;
  String? _error;

  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDummyNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDummyNotifications() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load dummy notifications
      await Future.wait([
        _loadDummyGeneralNotifications(),
        _loadDummyCrimeAlerts(),
        _loadDummyCommunityUpdates(),
      ]);

    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDummyGeneralNotifications() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final dummyNotifications = [
      {
        'id': 'notif_1',
        'title': 'Welcome to SafeZone',
        'subtitle': 'Your community safety app is ready to use. Start reporting and stay safe!',
        'time': _formatTime(DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String()),
        'type': 'welcome',
        'icon': Icons.waving_hand,
        'isRead': false,
        'priority': 'medium',
        'notificationId': null,
        'actionUrl': '/dashboard',
        'metadata': null,
      },
      {
        'id': 'notif_2',
        'title': 'Safety Tip',
        'subtitle': 'Always be aware of your surroundings when using ATMs, especially at night.',
        'time': _formatTime(DateTime.now().subtract(const Duration(hours: 2)).toIso8601String()),
        'type': 'safety_tip',
        'icon': Icons.lightbulb,
        'isRead': false,
        'priority': 'low',
        'notificationId': null,
        'actionUrl': null,
        'metadata': null,
      },
      {
        'id': 'notif_3',
        'title': 'Post Update',
        'subtitle': 'Your report about "Package stolen from porch" has been viewed 12 times.',
        'time': _formatTime(DateTime.now().subtract(const Duration(hours: 4)).toIso8601String()),
        'type': 'info',
        'icon': Icons.info,
        'isRead': true,
        'priority': 'low',
        'notificationId': null,
        'actionUrl': '/post',
        'metadata': null,
      },
      {
        'id': 'notif_4',
        'title': 'Weekly Report Reminder',
        'subtitle': 'Check your neighborhood safety report for this week.',
        'time': _formatTime(DateTime.now().subtract(const Duration(days: 1)).toIso8601String()),
        'type': 'reminder',
        'icon': Icons.notifications,
        'isRead': true,
        'priority': 'medium',
        'notificationId': null,
        'actionUrl': '/dashboard',
        'metadata': null,
      },
      {
        'id': 'notif_5',
        'title': 'App Update Available',
        'subtitle': 'Version 2.1.0 includes improved crime reporting and bug fixes.',
        'time': _formatTime(DateTime.now().subtract(const Duration(days: 2)).toIso8601String()),
        'type': 'app_update',
        'icon': Icons.system_update,
        'isRead': false,
        'priority': 'low',
        'notificationId': null,
        'actionUrl': null,
        'metadata': null,
      },
      {
        'id': 'notif_6',
        'title': 'Community Engagement',
        'subtitle': 'Great job! You\'ve helped make your neighborhood safer with 5 reports.',
        'time': _formatTime(DateTime.now().subtract(const Duration(days: 3)).toIso8601String()),
        'type': 'community',
        'icon': Icons.group,
        'isRead': true,
        'priority': 'low',
        'notificationId': null,
        'actionUrl': null,
        'metadata': null,
      },
      {
        'id': 'notif_7',
        'title': 'Account Security',
        'subtitle': 'Your password was successfully changed. If this wasn\'t you, contact support.',
        'time': _formatTime(DateTime.now().subtract(const Duration(days: 5)).toIso8601String()),
        'type': 'info',
        'icon': Icons.security,
        'isRead': true,
        'priority': 'medium',
        'notificationId': null,
        'actionUrl': '/settings',
        'metadata': null,
      },
      {
        'id': 'notif_8',
        'title': 'New Feature Alert',
        'subtitle': 'Try our new anonymous reporting feature for sensitive incidents.',
        'time': _formatTime(DateTime.now().subtract(const Duration(days: 7)).toIso8601String()),
        'type': 'info',
        'icon': Icons.new_releases,
        'isRead': false,
        'priority': 'low',
        'notificationId': null,
        'actionUrl': '/post',
        'metadata': null,
      },
    ];

    setState(() {
      _notifications = dummyNotifications;
    });
  }

  Future<void> _loadDummyCrimeAlerts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    final dummyCrimeAlerts = [
      {
        'id': 'crime_alert_1',
        'title': 'Theft Alert',
        'subtitle': 'Reported near Mirpur - Bicycle stolen from rack',
        'time': _formatTime(DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String()),
        'type': 'alert',
        'icon': Icons.shopping_bag,
        'isRead': false,
        'priority': 'high',
        'postId': 1,
        'location': 'Mirpur',
        'severity': 'medium',
        'crimeType': 'Theft',
      },
      {
        'id': 'crime_alert_2',
        'title': 'Assault Alert',
        'subtitle': 'Reported near Dhanmondi - Bar fight gets violent',
        'time': _formatTime(DateTime.now().subtract(const Duration(hours: 1)).toIso8601String()),
        'type': 'alert',
        'icon': Icons.person,
        'isRead': false,
        'priority': 'high',
        'postId': 2,
        'location': 'Dhanmondi',
        'severity': 'high',
        'crimeType': 'Assault',
      },
      {
        'id': 'crime_alert_3',
        'title': 'Burglary Alert',
        'subtitle': 'Reported near Gulshan - Garage burglary overnight',
        'time': _formatTime(DateTime.now().subtract(const Duration(hours: 3)).toIso8601String()),
        'type': 'alert',
        'icon': Icons.home,
        'isRead': true,
        'priority': 'high',
        'postId': 3,
        'location': 'Gulshan',
        'severity': 'high',
        'crimeType': 'Burglary',
      },
      {
        'id': 'crime_alert_4',
        'title': 'Theft Alert',
        'subtitle': 'Reported near Mohammadpur - Snatch theft at traffic light',
        'time': _formatTime(DateTime.now().subtract(const Duration(hours: 6)).toIso8601String()),
        'type': 'alert',
        'icon': Icons.shopping_bag,
        'isRead': false,
        'priority': 'high',
        'postId': 5,
        'location': 'Mohammadpur',
        'severity': 'medium',
        'crimeType': 'Theft',
      },
      {
        'id': 'crime_alert_5',
        'title': 'Harassment Alert',
        'subtitle': 'Reported near Uttara - Catcalling near school',
        'time': _formatTime(DateTime.now().subtract(const Duration(hours: 8)).toIso8601String()),
        'type': 'alert',
        'icon': Icons.warning,
        'isRead': true,
        'priority': 'high',
        'postId': 6,
        'location': 'Uttara',
        'severity': 'medium',
        'crimeType': 'Harassment',
      },
      {
        'id': 'crime_alert_6',
        'title': 'Theft Alert',
        'subtitle': 'Reported near Mirpur - Laptop stolen from café',
        'time': _formatTime(DateTime.now().subtract(const Duration(days: 1)).toIso8601String()),
        'type': 'alert',
        'icon': Icons.computer,
        'isRead': true,
        'priority': 'high',
        'postId': 11,
        'location': 'Mirpur',
        'severity': 'medium',
        'crimeType': 'Theft',
      },
      {
        'id': 'crime_alert_7',
        'title': 'Assault Alert',
        'subtitle': 'Reported near Dhanmondi - Road rage incident',
        'time': _formatTime(DateTime.now().subtract(const Duration(days: 1, hours: 4)).toIso8601String()),
        'type': 'alert',
        'icon': Icons.car_crash,
        'isRead': false,
        'priority': 'high',
        'postId': 12,
        'location': 'Dhanmondi',
        'severity': 'high',
        'crimeType': 'Assault',
      },
      {
        'id': 'crime_alert_8',
        'title': 'Burglary Alert',
        'subtitle': 'Reported near Gulshan - Office break-in over weekend',
        'time': _formatTime(DateTime.now().subtract(const Duration(days: 2)).toIso8601String()),
        'type': 'alert',
        'icon': Icons.business,
        'isRead': true,
        'priority': 'high',
        'postId': 23,
        'location': 'Gulshan',
        'severity': 'high',
        'crimeType': 'Burglary',
      },
      {
        'id': 'crime_alert_9',
        'title': 'Theft Alert',
        'subtitle': 'Reported near Mohammadpur - ATM mugging',
        'time': _formatTime(DateTime.now().subtract(const Duration(days: 3)).toIso8601String()),
        'type': 'alert',
        'icon': Icons.account_balance,
        'isRead': true,
        'priority': 'high',
        'postId': 25,
        'location': 'Mohammadpur',
        'severity': 'high',
        'crimeType': 'Theft',
      },
      {
        'id': 'crime_alert_10',
        'title': 'Suspicious Activity Alert',
        'subtitle': 'Reported near Karwan Bazar - Person checking car doors',
        'time': _formatTime(DateTime.now().subtract(const Duration(days: 4)).toIso8601String()),
        'type': 'alert',
        'icon': Icons.search,
        'isRead': false,
        'priority': 'medium',
        'postId': 30,
        'location': 'Karwan Bazar',
        'severity': 'medium',
        'crimeType': 'Suspicious Activity',
      },
    ];

    setState(() {
      _crimeAlerts = dummyCrimeAlerts;
    });
  }

  Future<void> _loadDummyCommunityUpdates() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));
    
    final dummyCommunityUpdates = [
      {
        'id': 'community_1',
        'title': 'Community Safety Meeting',
        'subtitle': 'Join us this Saturday at 3 PM at Community Center to discuss neighborhood security.',
        'time': _formatTime(DateTime.now().subtract(const Duration(hours: 2)).toIso8601String()),
        'type': 'community',
        'icon': Icons.group,
        'isRead': false,
        'priority': 'medium',
        'notificationId': null,
        'actionUrl': null,
        'metadata': {'event_date': '2025-07-05', 'location': 'Community Center'},
      },
      {
        'id': 'community_2',
        'title': 'Police Patrol Update',
        'subtitle': 'Increased police presence in Mirpur and Gulshan areas due to recent incidents.',
        'time': _formatTime(DateTime.now().subtract(const Duration(hours: 6)).toIso8601String()),
        'type': 'info',
        'icon': Icons.local_police,
        'isRead': false,
        'priority': 'high',
        'notificationId': null,
        'actionUrl': null,
        'metadata': null,
      },
      {
        'id': 'community_3',
        'title': 'Street Light Maintenance',
        'subtitle': 'Street lighting improvements completed in Dhanmondi area. Report any issues.',
        'time': _formatTime(DateTime.now().subtract(const Duration(days: 1)).toIso8601String()),
        'type': 'info',
        'icon': Icons.lightbulb_outline,
        'isRead': true,
        'priority': 'low',
        'notificationId': null,
        'actionUrl': null,
        'metadata': null,
      },
      {
        'id': 'community_4',
        'title': 'Neighborhood Watch Program',
        'subtitle': 'New volunteer program starting next week. Sign up to help keep our community safe.',
        'time': _formatTime(DateTime.now().subtract(const Duration(days: 2)).toIso8601String()),
        'type': 'community',
        'icon': Icons.visibility,
        'isRead': false,
        'priority': 'medium',
        'notificationId': null,
        'actionUrl': null,
        'metadata': {'signup_deadline': '2025-07-10'},
      },
      {
        'id': 'community_5',
        'title': 'Emergency Contact Update',
        'subtitle': 'New emergency hotline numbers have been added. Check the updated contact list.',
        'time': _formatTime(DateTime.now().subtract(const Duration(days: 3)).toIso8601String()),
        'type': 'info',
        'icon': Icons.phone_in_talk,
        'isRead': true,
        'priority': 'medium',
        'notificationId': null,
        'actionUrl': '/settings',
        'metadata': null,
      },
      {
        'id': 'community_6',
        'title': 'Safety Workshop',
        'subtitle': 'Free self-defense workshop this weekend at the community center. All welcome!',
        'time': _formatTime(DateTime.now().subtract(const Duration(days: 4)).toIso8601String()),
        'type': 'community',
        'icon': Icons.fitness_center,
        'isRead': true,
        'priority': 'low',
        'notificationId': null,
        'actionUrl': null,
        'metadata': {'workshop_date': '2025-07-06', 'time': '10:00 AM'},
      },
      {
        'id': 'community_7',
        'title': 'CCTV Installation Complete',
        'subtitle': 'New security cameras installed in high-crime areas. Coverage map updated.',
        'time': _formatTime(DateTime.now().subtract(const Duration(days: 5)).toIso8601String()),
        'type': 'info',
        'icon': Icons.videocam,
        'isRead': true,
        'priority': 'medium',
        'notificationId': null,
        'actionUrl': '/map',
        'metadata': null,
      },
      {
        'id': 'community_8',
        'title': 'Community App Contest',
        'subtitle': 'Share your safety tips and win prizes! Contest runs until month end.',
        'time': _formatTime(DateTime.now().subtract(const Duration(days: 7)).toIso8601String()),
        'type': 'community',
        'icon': Icons.emoji_events,
        'isRead': false,
        'priority': 'low',
        'notificationId': null,
        'actionUrl': null,
        'metadata': {'contest_end': '2025-07-31'},
      },
    ];

    setState(() {
      _communityUpdates = dummyCommunityUpdates;
    });
  }

  // Keep all the existing helper methods
  IconData _getCrimeIcon(String? iconName) {
    switch (iconName) {
      case 'theft':
        return Icons.shopping_bag;
      case 'assault':
        return Icons.person;
      case 'vandalism':
        return Icons.broken_image;
      case 'burglary':
        return Icons.home;
      case 'vehicle':
        return Icons.directions_car;
      default:
        return Icons.warning;
    }
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'alert':
        return Icons.warning;
      case 'info':
        return Icons.info;
      case 'reminder':
        return Icons.notifications;
      case 'community':
        return Icons.group;
      case 'safety_tip':
        return Icons.lightbulb;
      case 'app_update':
        return Icons.system_update;
      case 'welcome':
        return Icons.waving_hand;
      default:
        return Icons.notifications;
    }
  }

  String _getNotificationPriority(String? type) {
    switch (type) {
      case 'alert':
      case 'emergency':
        return 'high';
      case 'reminder':
      case 'community':
        return 'medium';
      case 'info':
      case 'safety_tip':
      case 'app_update':
        return 'low';
      default:
        return 'low';
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return 'Unknown time';
    
    try {
      final DateTime dateTime = DateTime.parse(timestamp);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours} hrs ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${(difference.inDays / 7).floor()} weeks ago';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }

  Color _getPriorityColor(String priority, bool isDark) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return isDark ? Colors.white70 : Colors.grey[600]!;
      default:
        return isDark ? Colors.white70 : Colors.grey[600]!;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'alert':
        return Colors.red;
      case 'info':
        return Colors.blue;
      case 'reminder':
        return Colors.orange;
      case 'community':
        return Colors.green;
      case 'safety_tip':
        return Colors.purple;
      case 'app_update':
        return Colors.teal;
      case 'welcome':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  void _markAsRead(String notificationId, String tab) {
    setState(() {
      switch (tab) {
        case 'all':
          _notifications = _notifications.map((notif) {
            if (notif['id'] == notificationId) {
              notif['isRead'] = true;
            }
            return notif;
          }).toList();
          break;
        case 'alerts':
          _crimeAlerts = _crimeAlerts.map((alert) {
            if (alert['id'] == notificationId) {
              alert['isRead'] = true;
            }
            return alert;
          }).toList();
          break;
        case 'community':
          _communityUpdates = _communityUpdates.map((update) {
            if (update['id'] == notificationId) {
              update['isRead'] = true;
            }
            return update;
          }).toList();
          break;
      }
    });
  }

  void _onNotificationTap(Map<String, dynamic> notification) async {
    // Mark as read if it's a real notification from database
    if (notification['notificationId'] != null) {
      try {
        await _supabaseService.markNotificationAsRead(notification['notificationId']);
      } catch (e) {
        print('Error marking notification as read: $e');
      }
    }
    
    // Mark as read in local state
    _markAsRead(notification['id'], _getCurrentTabName());
    
    // Handle different notification actions
    if (notification['actionUrl'] != null) {
      // Handle action URL navigation
      final actionUrl = notification['actionUrl'] as String;
      if (actionUrl.startsWith('/')) {
        // Internal navigation
        Navigator.pushNamed(context, actionUrl);
      }
    } else {
      // Handle default actions based on type
      switch (notification['type']) {
        case 'alert':
          // Navigate to post details if it's a crime alert
          if (notification['postId'] != null) {
            // Navigator.pushNamed(context, '/post-details', arguments: notification['postId']);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Opening details for ${notification['crimeType']} in ${notification['location']}')),
            );
          }
          break;
        case 'reminder':
          // Handle different reminder types
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reminder noted!')),
          );
          break;
        case 'community':
          // Navigate to community section
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opening community section...')),
          );
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Notification: ${notification['title']}')),
          );
      }
    }
  }

  String _getCurrentTabName() {
    switch (_tabController.index) {
      case 0:
        return 'all';
      case 1:
        return 'alerts';
      case 2:
        return 'community';
      default:
        return 'all';
    }
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/map');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/post');
        break;
      case 3:
        // Already on Inbox
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
  }

  Widget _buildNotificationsList(List<Map<String, dynamic>> notifications, String tabType) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDummyNotifications,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final isRead = notification['isRead'] ?? false;

          return Card(
            elevation: isRead ? 1 : 3,
            color: isRead 
                ? (isDark ? Colors.grey[800] : Colors.grey[50])
                : (isDark ? Colors.grey[900] : Colors.white),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getTypeColor(notification['type']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  notification['icon'],
                  color: _getTypeColor(notification['type']),
                  size: 24,
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      notification['title'] ?? '',
                      style: TextStyle(
                        fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  if (!isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getTypeColor(notification['type']),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    notification['subtitle'] ?? '',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification['time'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.grey,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(notification['priority'] ?? 'low', isDark).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getPriorityColor(notification['priority'] ?? 'low', isDark).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          notification['priority']?.toUpperCase() ?? 'LOW',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _getPriorityColor(notification['priority'] ?? 'low', isDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () => _onNotificationTap(notification),
            ),
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalUnread = (_notifications.where((n) => !(n['isRead'] ?? false)).length +
        _crimeAlerts.where((n) => !(n['isRead'] ?? false)).length +
        _communityUpdates.where((n) => !(n['isRead'] ?? false)).length);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'Inbox',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (totalUnread > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$totalUnread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        centerTitle: false,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: null,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? Colors.white : Colors.black,
          unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: [
            Tab(
              text: 'All',
              icon: _notifications.any((n) => !(n['isRead'] ?? false))
                  ? const Icon(Icons.circle, size: 8, color: Colors.red)
                  : null,
            ),
            Tab(
              text: 'Alerts',
              icon: _crimeAlerts.any((n) => !(n['isRead'] ?? false))
                  ? const Icon(Icons.circle, size: 8, color: Colors.red)
                  : null,
            ),
            Tab(
              text: 'Community',
              icon: _communityUpdates.any((n) => !(n['isRead'] ?? false))
                  ? const Icon(Icons.circle, size: 8, color: Colors.red)
                  : null,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading notifications',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: null,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNotificationsList([..._notifications, ..._crimeAlerts, ..._communityUpdates], 'all'),
                    _buildNotificationsList(_crimeAlerts, 'alerts'),
                    _buildNotificationsList(_communityUpdates, 'community'),
                  ],
                ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
