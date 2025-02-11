import 'package:flutter/material.dart';
import '../styles/colors.dart';
import '../styles/fonts.dart';

class ConfirmButton extends StatelessWidget {
  final VoidCallback onPressed;
  const ConfirmButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.salmon,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text('Confirm', style: Fonts.LanguageButtonActive),
        ),
      ),
    );
  }
}
