import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../widgets/common/app_bar_widget.dart';
import '../constants/app_constants.dart';
import '../themes/app_themes.dart';
import '../widgets/common/bottom_navigation_widget.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool eventNotifications = true;
  bool gradeNotifications = false;
  bool messageNotifications = true;
  bool clubNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      eventNotifications = prefs.getBool('eventNotifications') ?? true;
      gradeNotifications = prefs.getBool('gradeNotifications') ?? false;
      messageNotifications = prefs.getBool('messageNotifications') ?? true;
      clubNotifications = prefs.getBool('clubNotifications') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('eventNotifications', eventNotifications);
    await prefs.setBool('gradeNotifications', gradeNotifications);
    await prefs.setBool('messageNotifications', messageNotifications);
    await prefs.setBool('clubNotifications', clubNotifications);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.notificationSettingsSaved,
          ),
          backgroundColor: AppThemes.getPrimaryColor(context),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) Navigator.pop(context);
    }
  }

  Widget _buildNotificationItem({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: AppThemes.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppThemes.getPrimaryColor(context),
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppThemes.getTextColor(context),
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppThemes.getPrimaryColor(context),
          activeTrackColor: AppThemes.getPrimaryColor(
            context,
          ).withValues(alpha: 0.2),
          inactiveThumbColor: isDark ? Colors.white70 : Colors.grey.shade400,
          inactiveTrackColor: isDark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.grey.shade200,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.getBackgroundColor(context),
      appBar: ModernAppBar(
        title: AppLocalizations.of(context)!.notificationSettings,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Basit açıklama
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Bildirim tercihlerinizi yönetin',
              style: TextStyle(
                fontSize: 14,
                color: AppThemes.getSecondaryTextColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Bildirim seçenekleri
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNotificationItem(
                  title: AppLocalizations.of(context)!.eventNotifications,
                  icon: Icons.event_outlined,
                  value: eventNotifications,
                  onChanged: (val) {
                    setState(() => eventNotifications = val ?? false);
                  },
                ),
                _buildNotificationItem(
                  title: AppLocalizations.of(context)!.gradeNotifications,
                  icon: Icons.school_outlined,
                  value: gradeNotifications,
                  onChanged: (val) {
                    setState(() => gradeNotifications = val ?? false);
                  },
                ),
                _buildNotificationItem(
                  title: AppLocalizations.of(context)!.messageNotifications,
                  icon: Icons.mail_outlined,
                  value: messageNotifications,
                  onChanged: (val) {
                    setState(() => messageNotifications = val ?? false);
                  },
                ),
                _buildNotificationItem(
                  title: AppLocalizations.of(context)!.clubNotifications,
                  icon: Icons.group_outlined,
                  value: clubNotifications,
                  onChanged: (val) {
                    setState(() => clubNotifications = val ?? false);
                  },
                ),
              ],
            ),
          ),

          // Kaydet butonu
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemes.getPrimaryColor(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  AppLocalizations.of(context)!.save,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigationWidget(
        currentIndex: AppConstants.navIndexProfile,
      ),
    );
  }
}
