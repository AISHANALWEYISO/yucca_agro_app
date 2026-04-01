import 'package:flutter/material.dart';
import 'services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiService _api = ApiService();
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  static const Color colorLogoGreen = Color(0xFF366000);

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      // TODO: Replace with actual API call
      // final response = await http.get(Uri.parse('${_api.baseUrl}/notifications'));
      
      // Mock data for now
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        _notifications = [
          {'title': 'Welcome to Yucca!', 'body': 'Start by checking your crop calendar.', 'time': '2 min ago', 'read': false},
          {'title': 'Weather Alert', 'body': 'Heavy rain expected in Kampala tomorrow.', 'time': '1 hour ago', 'read': false},
          {'title': 'New Tip Added', 'body': 'Learn about organic pest control methods.', 'time': '3 hours ago', 'read': true},
          {'title': 'Soil Scanner Update', 'body': 'New crop recommendations available.', 'time': '1 day ago', 'read': true},
        ];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load notifications: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Updates'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colorLogoGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNotifications,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No new updates', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final note = _notifications[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: note['read'] ? Colors.grey[200] : colorLogoGreen,
                        child: Icon(
                          Icons.campaign,
                          color: note['read'] ? Colors.grey[600] : Colors.white,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        note['title'],
                        style: TextStyle(
                          fontWeight: note['read'] ? FontWeight.normal : FontWeight.bold,
                          color: colorLogoGreen,
                        ),
                      ),
                      subtitle: Text(note['body'], style: TextStyle(color: Colors.grey[700])),
                      trailing: Text(
                        note['time'],
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                      onTap: () {
                        // Mark as read + show details
                        setState(() => _notifications[index]['read'] = true);
                        // TODO: Navigate to detail screen if needed
                      },
                    );
                  },
                ),
    );
  }
}