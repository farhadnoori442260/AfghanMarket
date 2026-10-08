import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/screens/auth/login_screen.dart';

class LargeHeadingWidget extends StatelessWidget {
  final String heading;
  final double? headingTextSize;
  final Color? headingTextColor;
  final String subHeading;
  final double? subheadingTextSize;
  final Color? subheadingTextColor;
  final String? anotherTaglineText;
  final Color? anotherTaglineColor;
  final bool? taglineNavigation;

  const LargeHeadingWidget({
    Key? key,
    required this.heading,
    required this.subHeading,
    this.subheadingTextSize,
    this.headingTextSize,
    this.subheadingTextColor,
    this.headingTextColor,
    this.anotherTaglineText,
    this.anotherTaglineColor,
    this.taglineNavigation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            heading,
            style: TextStyle(
              color: headingTextColor ?? blackColor,
              fontSize: headingTextSize ?? 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              text: subHeading,
              style: TextStyle(
                color: subheadingTextColor ?? greyColor,
                fontSize: subheadingTextSize ?? 18,
                height: 1.4,
              ),
              children: [
                if (anotherTaglineText != null) ...[
                  const TextSpan(text: ' '),
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = taglineNavigation == true
                          ? () {
                              Navigator.pushReplacementNamed(
                                  context, LoginScreen.screenId);
                            }
                          : null,
                    text: anotherTaglineText,
                    style: TextStyle(
                      color: anotherTaglineColor ?? primaryColor,
                      fontSize: subheadingTextSize ?? 18,
                      fontWeight: FontWeight.bold,
                      decoration: taglineNavigation == true
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
