import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

/// Ortak AppBar widget'ı / Common AppBar widget
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool automaticallyImplyLeading;

  const CommonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppConstants.primaryColor,
      foregroundColor: AppConstants.textColorLight,
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: AppConstants.fontSizeXLarge,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppConstants.appBarHeight);
}
