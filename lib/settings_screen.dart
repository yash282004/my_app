import 'package:flutter/material.dart';
import 'glassmorphic_container.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkTheme = true;
  bool _notificationsEnabled = true;
  String _temperatureUnit = 'Celsius';
  String _windSpeedUnit = 'km/h';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2C3E50),
                  Color(0xFF34495E),
                ],
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          // Navigate back
                        },
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Settings Options
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // Theme Setting
                      _buildSettingItem(
                        icon: Icons.brightness_6,
                        title: 'Dark Theme',
                        subtitle: 'Switch between light and dark mode',
                        trailing: Switch(
                          value: _isDarkTheme,
                          onChanged: (value) {
                            setState(() {
                              _isDarkTheme = value;
                            });
                          },
                          activeColor: Colors.blue,
                        ),
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Notifications
                      _buildSettingItem(
                        icon: Icons.notifications,
                        title: 'Notifications',
                        subtitle: 'Enable weather alerts and updates',
                        trailing: Switch(
                          value: _notificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });
                          },
                          activeColor: Colors.blue,
                        ),
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Temperature Unit
                      _buildSettingItem(
                        icon: Icons.thermostat,
                        title: 'Temperature Unit',
                        subtitle: _temperatureUnit,
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          onSelected: (value) {
                            setState(() {
                              _temperatureUnit = value;
                            });
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'Celsius',
                              child: Text('Celsius (°C)'),
                            ),
                            const PopupMenuItem(
                              value: 'Fahrenheit',
                              child: Text('Fahrenheit (°F)'),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Wind Speed Unit
                      _buildSettingItem(
                        icon: Icons.air,
                        title: 'Wind Speed Unit',
                        subtitle: _windSpeedUnit,
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          onSelected: (value) {
                            setState(() {
                              _windSpeedUnit = value;
                            });
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'km/h',
                              child: Text('km/h'),
                            ),
                            const PopupMenuItem(
                              value: 'mph',
                              child: Text('mph'),
                            ),
                            const PopupMenuItem(
                              value: 'm/s',
                              child: Text('m/s'),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // About
                      _buildSettingItem(
                        icon: Icons.info,
                        title: 'About',
                        subtitle: 'App version and information',
                        onTap: () {
                          _showAboutDialog();
                        },
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Support
                      _buildSettingItem(
                        icon: Icons.support,
                        title: 'Support',
                        subtitle: 'Get help and support',
                        onTap: () {
                          _showSupportDialog();
                        },
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Reset Settings Button
                      GlassmorphicContainer(
                        width: double.infinity,
                        height: 60,
                        borderRadius: 20,
                        blur: 15,
                        border: 1,
                        linearGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.red.withOpacity(0.2),
                            Colors.red.withOpacity(0.1),
                          ],
                        ),
                        borderGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.red.withOpacity(0.3),
                            Colors.red.withOpacity(0.1),
                          ],
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.restore,
                            color: Colors.red,
                          ),
                          title: const Text(
                            'Reset to Default',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: _resetSettings,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 80,
      borderRadius: 20,
      blur: 15,
      border: 1,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.1),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 30),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C3E50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Reset Settings',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to reset all settings to default?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isDarkTheme = true;
                _notificationsEnabled = true;
                _temperatureUnit = 'Celsius';
                _windSpeedUnit = 'km/h';
              });
              Navigator.pop(context);
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C3E50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'About Weather Storyboard',
          style: TextStyle(color: Colors.white),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 10),
            Text(
              'A beautiful weather app with glassmorphism design, real-time data, and stunning animations.',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 10),
            Text(
              'Powered by OpenWeatherMap API',
              style: TextStyle(color: Colors.blue, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C3E50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Support',
          style: TextStyle(color: Colors.white),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Need help? Contact us:',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 10),
            Text(
              '📧 support@weatherstoryboard.com',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 5),
            Text(
              '🌐 www.weatherstoryboard.com',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 5),
            Text(
              '📱 +1 (555) 123-4567',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}