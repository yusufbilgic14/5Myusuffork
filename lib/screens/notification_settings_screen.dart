import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../widgets/common/app_bar_widget.dart';

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
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
        title: AppLocalizations.of(context)!.notificationSettings,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'Menü',
            );
          },
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(24),
            children: [
              CheckboxListTile(
                title: Text(AppLocalizations.of(context)!.eventNotifications),
                value: eventNotifications,
                onChanged: (val) {
                  setState(() => eventNotifications = val ?? false);
                },
              ),
              CheckboxListTile(
                title: Text(AppLocalizations.of(context)!.gradeNotifications),
                value: gradeNotifications,
                onChanged: (val) {
                  setState(() => gradeNotifications = val ?? false);
                },
              ),
              CheckboxListTile(
                title: Text(AppLocalizations.of(context)!.messageNotifications),
                value: messageNotifications,
                onChanged: (val) {
                  setState(() => messageNotifications = val ?? false);
                },
              ),
              CheckboxListTile(
                title: Text(AppLocalizations.of(context)!.clubNotifications),
                value: clubNotifications,
                onChanged: (val) {
                  setState(() => clubNotifications = val ?? false);
                },
              ),
            ],
          ),
          Positioned(
            right: 24,
            bottom: 24,
            child: FloatingActionButton.extended(
              onPressed: _saveSettings,
              backgroundColor: const Color(0xFF1E3A8A),
              icon: const Icon(Icons.save),
              label: Text(AppLocalizations.of(context)!.save),
            ),
          ),
        ],
      ),
    );
  }
}
