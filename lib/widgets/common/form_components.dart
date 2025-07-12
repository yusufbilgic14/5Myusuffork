import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../themes/app_themes.dart';

/// Özel giriş alanı widget'ı / Custom input field widget
class CustomInputField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool isPassword;
  final bool isRequired;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool readOnly;
  final int? maxLines;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;

  const CustomInputField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.isPassword = false,
    this.isRequired = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = AppConstants.radiusSmall,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor =
        backgroundColor ??
        (textColor == Colors.white
            ? Colors.white
            : AppThemes.getSurfaceColor(context));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: textColor ?? AppThemes.getTextColor(context),
              fontSize: AppConstants.fontSizeMedium,
              fontWeight: FontWeight.w500,
            ),
            children: isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]
                : null,
          ),
        ),

        const SizedBox(height: AppConstants.paddingSmall),

        // Input field
        Container(
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: backgroundColor == null ? AppShadows.card : null,
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            validator: validator,
            onTap: onTap,
            readOnly: readOnly,
            maxLines: maxLines,
            style: TextStyle(
              color: textColor == Colors.white
                  ? Colors.black87
                  : AppThemes.getTextColor(context),
              fontSize: AppConstants.fontSizeMedium,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: AppConstants.fontSizeMedium,
              ),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: maxLines == 1
                    ? AppConstants.paddingSmall + 4
                    : AppConstants.paddingMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Kategori seçim kartı / Category selection card
class CategorySelectionCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const CategorySelectionCard({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : AppThemes.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppShadows.elevated : AppShadows.card,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey[600], size: 32),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppConstants.fontSizeSmall,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : AppThemes.getTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dropdown seçim alanı / Dropdown selection field
class CustomDropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool isRequired;
  final Color? textColor;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isRequired = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: textColor ?? AppThemes.getTextColor(context),
              fontSize: AppConstants.fontSizeMedium,
              fontWeight: FontWeight.w500,
            ),
            children: isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]
                : null,
          ),
        ),

        const SizedBox(height: AppConstants.paddingSmall),

        // Dropdown field
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
          ),
          decoration: BoxDecoration(
            color: AppThemes.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            boxShadow: AppShadows.card,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value.isEmpty ? null : value,
              isExpanded: true,
              hint: Text(
                'Seçiniz...',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: AppConstants.fontSizeMedium,
                ),
              ),
              style: TextStyle(
                color: AppThemes.getTextColor(context),
                fontSize: AppConstants.fontSizeMedium,
              ),
              items: items.map((item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

/// Checkbox list item / Checkbox liste öğesi
class CustomCheckboxListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final IconData? leadingIcon;

  const CustomCheckboxListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppThemes.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        boxShadow: AppShadows.card,
      ),
      child: CheckboxListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: AppConstants.fontSizeMedium,
            fontWeight: FontWeight.w500,
            color: AppThemes.getTextColor(context),
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSmall,
                  color: AppThemes.getSecondaryTextColor(context),
                ),
              )
            : null,
        value: value,
        onChanged: onChanged,
        activeColor: AppThemes.getPrimaryColor(context),
        secondary: leadingIcon != null
            ? Icon(leadingIcon, color: AppThemes.getPrimaryColor(context))
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: 4,
        ),
      ),
    );
  }
}

/// Aksiyon butonu / Action button
class CustomActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;

  const CustomActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor =
        backgroundColor ??
        (isPrimary ? AppThemes.getPrimaryColor(context) : Colors.transparent);
    final effectiveTextColor =
        textColor ??
        (isPrimary ? Colors.white : AppThemes.getPrimaryColor(context));

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: isPrimary
          ? ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: effectiveBackgroundColor,
                foregroundColor: effectiveTextColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                elevation: 2,
              ),
              child: _buildButtonContent(),
            )
          : OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: effectiveTextColor,
                side: BorderSide(color: effectiveTextColor, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
              ),
              child: _buildButtonContent(),
            ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: AppConstants.paddingSmall),
          Text(
            text,
            style: const TextStyle(
              fontSize: AppConstants.fontSizeMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: const TextStyle(
        fontSize: AppConstants.fontSizeMedium,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
