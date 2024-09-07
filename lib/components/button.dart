import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const Button({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      focusElevation: 0,
      highlightElevation: 0,
      highlightColor: const Color(0xff399918),
      splashColor: const Color(0xff399918),
      color: const Color(0xff399918),
      textColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      // minWidth: MediaQuery.of(context).size.width,
      onPressed: onPressed,
      child: child,
    );
  }
}
