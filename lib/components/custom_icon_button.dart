import 'package:flutter/material.dart';
import 'package:kalino_app/constants/colors.dart';

class CustomIconButton extends StatelessWidget {
  final String? text;
  final String? imageIcon;
  final IconData? icon;
  final Color? imageOrIconColor;
  final double? imageOrIconSize;
  final Color? bgColor;
  final Color? textColor;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final double? borderRadius;
  final Border? border;

  const CustomIconButton({
    Key? key,
    this.text,
    this.imageIcon,
    this.icon,
    this.imageOrIconColor,
    this.imageOrIconSize = 22,
    this.bgColor,
    this.textColor,
    this.padding,
    this.onTap,
    this.borderRadius = 16,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color effectiveBgColor = bgColor ?? primaryColor;
    final Color effectiveTextColor = textColor ??
        (effectiveBgColor == whiteColor ? blackColor : whiteColor);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius!),
        child: Container(
          decoration: BoxDecoration(
            color: effectiveBgColor,
            borderRadius: BorderRadius.circular(borderRadius!),
            border: border,
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: padding ??
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (imageIcon != null) ...[
                Image.asset(
                  imageIcon!,
                  color: imageOrIconColor,
                  height: imageOrIconSize,
                  width: imageOrIconSize,
                ),
                if (text != null) const SizedBox(width: 12),
              ],
              if (icon != null) ...[
                Icon(
                  icon,
                  size: imageOrIconSize,
                  color: imageOrIconColor ?? effectiveTextColor,
                ),
                if (text != null) const SizedBox(width: 12),
              ],
              if (text != null)
                Flexible(
                  child: Text(
                    text!,
                    style: TextStyle(
                      color: effectiveTextColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
