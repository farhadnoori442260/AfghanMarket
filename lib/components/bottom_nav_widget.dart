import 'package:flutter/material.dart';
import 'package:kalino_app/constants/colors.dart';

class BottomNavigationWidget extends StatelessWidget {
  final bool validator;
  final VoidCallback? onPressed;
  final String buttonText;
  final bool isLoading;

  const BottomNavigationWidget({
    Key? key,
    required this.validator,
    this.onPressed,
    required this.buttonText,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: validator ? 2 : 0,
                shadowColor: primaryColor.withOpacity(0.4),
                backgroundColor: validator ? primaryColor : disabledColor.withOpacity(0.3),
                foregroundColor: validator ? whiteColor : greyMediumColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: (validator && !isLoading) ? onPressed : null,
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                      ),
                    )
                  : Text(
                      buttonText,
                      style: TextStyle(
                        color: validator ? whiteColor : greyMediumColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
