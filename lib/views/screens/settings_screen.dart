// lib/views/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:tiktok_tutorial/helpers/database_helper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  void _resetDatabase(BuildContext context) async {
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Database'),
        content: const Text('Are you sure you want to reset the database? This will delete all user data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm) {
      await DatabaseHelper().resetDatabase();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database has been reset.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _resetDatabase(context),
          child: const Text('Reset Database'),
        ),
      ),
    );
  }
}
