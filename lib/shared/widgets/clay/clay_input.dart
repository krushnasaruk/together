import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_tokens.dart';

/// Modern tactile input field with clean high-contrast styling,
/// animated focus glow, smooth error presentation, and comfortable touch targets.
class ClayInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final bool autofocus;
  final bool enabled;

  const ClayInput({
    super.key,
    this.controller,
    this.initialValue,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.autofocus = false,
    this.enabled = true,
  });

  @override
  State<ClayInput> createState() => _ClayInputState();
}

class _ClayInputState extends State<ClayInput> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() => _isFocused = _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    return FormField<String>(
      initialValue: widget.controller?.text ?? widget.initialValue ?? '',
      validator: widget.validator,
      builder: (FormFieldState<String> fieldState) {
        final hasError = fieldState.hasError;

        Color borderColor;
        if (hasError) {
          borderColor = AppColors.error;
        } else if (_isFocused) {
          borderColor = primaryColor;
        } else {
          borderColor =
              isDark ? const Color(0xFF2E3630) : const Color(0xFFE2DDD5);
        }

        final containerBg =
            isDark ? const Color(0xFF1B201D) : const Color(0xFFFFFFFF);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Crisp Label
            if (widget.labelText != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
                child: Text(
                  widget.labelText!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: hasError
                        ? AppColors.error
                        : (_isFocused
                            ? primaryColor
                            : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textPrimary)),
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ],

            // 2. High-Contrast Tactile Input Surface
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: containerBg,
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                border: Border.all(
                  color: borderColor,
                  width: _isFocused ? 1.8 : 1.2,
                ),
                boxShadow: [
                  if (_isFocused && !hasError)
                    BoxShadow(
                      color: primaryColor.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.35 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                crossAxisAlignment: widget.maxLines > 1
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  // Prefix Icon with optional subtle rounded backdrop
                  if (widget.prefixIcon != null) ...[
                    Padding(
                      padding: EdgeInsets.only(
                        top: widget.maxLines > 1 ? 12.0 : 0.0,
                        right: 8.0,
                      ),
                      child: IconTheme(
                        data: IconThemeData(
                          color: _isFocused
                              ? primaryColor
                              : (isDark ? Colors.white60 : Colors.black45),
                          size: 20,
                        ),
                        child: widget.prefixIcon!,
                      ),
                    ),
                  ],

                  // Editable Text Area
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      enabled: widget.enabled,
                      obscureText: widget.obscureText,
                      keyboardType: widget.keyboardType,
                      maxLines: widget.maxLines,
                      autofocus: widget.autofocus,
                      cursorColor: primaryColor,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                      onChanged: (value) {
                        fieldState.didChange(value);
                        widget.onChanged?.call(value);
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 4,
                        ),
                        hintText: widget.hintText,
                        hintStyle: TextStyle(
                          color: isDark
                              ? const Color(0xFF6B756E)
                              : const Color(0xFF9E988F),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),

                  // Suffix Icon / Actions (Password Toggle etc.)
                  if (widget.suffixIcon != null) ...[
                    IconTheme(
                      data: IconThemeData(
                        color: isDark ? Colors.white60 : Colors.black45,
                        size: 20,
                      ),
                      child: widget.suffixIcon!,
                    ),
                  ],
                ],
              ),
            ),

            // 3. Crisp Error Message Row (Never alters input container height)
            if (hasError && fieldState.errorText != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 6.0, top: 5.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 13,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        fieldState.errorText!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
