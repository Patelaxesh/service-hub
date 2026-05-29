import 'package:flutter/material.dart';
import 'AboutPage.dart';
import 'HelpandSupport.dart'; // Import your Help & Support screen
import 'FeedbackScreen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> settingsOptions = [
      {
        'icon': Icons.lock,
        'title': 'Privacy',
        'subtitle': 'Adjust your privacy settings',
        'onTap': () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Privacy settings coming soon!")),
            ),
      },
      {
        'icon': Icons.brightness_6,
        'title': 'Theme',
        'subtitle': 'Switch between light and dark mode',
        'onTap': () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Theme settings coming soon!")),
            ),
      },
      {
        'icon': Icons.feedback,
        'title': 'Feedback',
        'subtitle': 'Send your feedback to us',
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FeedbackScreen()),
            ),
      },
      {
        'icon': Icons.help,
        'title': 'Help & Support',
        'subtitle': 'Get assistance and support',
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HelpSupportPage()),
            ),
      },
      {
        'icon': Icons.info,
        'title': 'About',
        'subtitle': 'Learn more about this app',
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AboutPage()),
            ),
      },
      {
        'icon': Icons.language,
        'title': 'Language',
        'subtitle': 'English (Default)',
        'onTap': () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Language settings coming soon!",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                backgroundColor: Colors.green,
              ),
            ),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.redAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: settingsOptions
            .map((item) => Column(
                  children: [
                    ListTile(
                      leading: Icon(item['icon']),
                      title: Text(item['title']),
                      subtitle: Text(item['subtitle']),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: item['onTap'],
                    ),
                    const Divider(),
                  ],
                ))
            .toList(),
      ),
    );
  }
}
