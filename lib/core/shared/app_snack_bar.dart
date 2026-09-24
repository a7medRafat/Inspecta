import 'package:flutter/material.dart';

import '../consts/app_colors.dart';

enum SnackBarType { error, warning, success, info }

extension SnackBarTypeExtension on SnackBarType {
  IconData get icon {
    switch (this) {
      case SnackBarType.error:
        return Icons.error_outline;
      case SnackBarType.warning:
        return Icons.warning_rounded;
      case SnackBarType.success:
        return Icons.check_rounded;
      case SnackBarType.info:
        return Icons.info_rounded;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case SnackBarType.error:
        return const Color(0xFFFFEFEF);
      case SnackBarType.warning:
        return const Color(0xFFFFF9E5);
      case SnackBarType.success:
        return const Color(0xFFE9F7F1);
      case SnackBarType.info:
        return const Color.fromARGB(255, 245, 231, 221);
    }
  }

  Color get iconColor {
    switch (this) {
      case SnackBarType.error:
        return const Color(0xFFFF4D4D);
      case SnackBarType.warning:
        return const Color(0xFFFFB800);
      case SnackBarType.success:
        return AppColours.green;
      case SnackBarType.info:
        return const Color(0xFF0085FF);
    }
  }
}

class AnimatedSnackBar extends StatefulWidget {
  final String title;
  final String message;
  final SnackBarType type;
  final VoidCallback? onClose;
  final void Function()? buttonPressed;
  final String? buttonText;

  const AnimatedSnackBar({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    this.onClose,
    this.buttonPressed,
    this.buttonText,
  });

  @override
  State<AnimatedSnackBar> createState() => _AnimatedSnackBarState();
}

class _AnimatedSnackBarState extends State<AnimatedSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linearToEaseOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: Curves.linearToEaseOut),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [widget.type.backgroundColor, Colors.white],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 15,
                spreadRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// First Row: Icon - Title - Close
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      widget.type.icon,
                      size: 24,
                      color: widget.type.iconColor,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _controller.reverse().then((value) {
                          widget.onClose?.call();
                        });
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        color: Colors.transparent,
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),
                Center(
                  child: Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
