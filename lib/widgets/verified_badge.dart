import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class VerifiedBadge extends StatelessWidget {
  final double size;

  const VerifiedBadge({super.key, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.verifiedGreen,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check_rounded,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
}
