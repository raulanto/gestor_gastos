import 'package:flutter/material.dart';
import '../widgets/settings_user_profile.dart';
import '../widgets/settings_theme_card.dart';
import '../widgets/settings_management_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        centerTitle: false,
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsUserProfile(),
              SettingsThemeCard(),
              SizedBox(height: 24),
              SettingsManagementCard(),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
