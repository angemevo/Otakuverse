import 'package:flutter/material.dart';
import 'package:otakuverse/core/constants/colors.dart';
import 'package:otakuverse/core/constants/text_styles.dart';

enum InputStatus { error, normal, success , focused, disabled }

class StandardInput extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final InputStatus status;
  final bool enabled;
  final String? errorText;

  const StandardInput({
    super.key,
    required this.hint,
    required this.controller,
    this.status = InputStatus.normal,
    this.enabled = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color borderColor = AppColors.mediumGray;
    Color backgroundColor =
        isDark ? AppColors.darkGray : Colors.white;

    if (!enabled || status == InputStatus.disabled) {
      backgroundColor = AppColors.darkGray;
    }

    switch (status) {
      case InputStatus.focused:
        borderColor = AppColors.crimsonRed;
        break;
      case InputStatus.error:
        borderColor = AppColors.errorRed;
        break;
      case InputStatus.success:
        borderColor = Colors.green;
        break;
      default:
        borderColor = AppColors.mediumGray;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          enabled: enabled,
          style: AppTextStyles.inputHint,
          decoration: InputDecoration(
            filled: true,
            fillColor: backgroundColor,
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.mediumGray,
              fontSize: 14,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            enabledBorder: _border(borderColor),
            focusedBorder: _border(borderColor),
            suffixIcon: status == InputStatus.success
                ? const Icon(Icons.check_circle, color: AppColors.successGreen)
                : null,
          ),
        ),

        if (status == InputStatus.error && errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: const TextStyle(color: AppColors.errorRed, fontSize: 12),
          ),
        ],
      ],
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: 1),
    );
  }
}
