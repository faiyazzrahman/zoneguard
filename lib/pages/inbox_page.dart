import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  int _currentIndex = 3;

  final List<Map<String, String>> _dummyNotifications = [
    {
      'title': 'Suspicious Activity Reported',
      'subtitle': 'An incident was reported near Elm Street.',
      'time': '2 hrs ago',
    },
    {
      'title': 'New Crime Alert',
      'subtitle': 'Robbery reported in Downtown area.',
      'time': '5 hrs ago',
    },
    {
      'title': 'Community Watch Update',
      'subtitle': 'Neighborhood meeting scheduled for Friday.',
      'time': '1 day ago',
    },
    {
      'title': 'Incident Resolved',
      'subtitle': 'Suspicious person near Pine Avenue was apprehended.',
      'time': '2 days ago',
    },
    {
      'title': 'Safety Tip',
      'subtitle': 'Remember to lock your doors at night.',
      'time': '3 days ago',
    },
  ];

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 0,
        title: Text(
          'Inbox',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: _dummyNotifications.isEmpty
          ? Center(
              child: Text(
                'No notifications at the moment.',
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.white70 : Colors.grey[700],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _dummyNotifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notif = _dummyNotifications[index];
                return ListTile(
                  leading: Icon(Icons.notifications, color: isDark ? Colors.white70 : Colors.blue),
                  title: Text(
                    notif['title'] ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    notif['subtitle'] ?? '',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  trailing: Text(
                    notif['time'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
                  ),
                  onTap: () {
                    // You can add notification tap behavior here
                  },
                );
              },
            ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
