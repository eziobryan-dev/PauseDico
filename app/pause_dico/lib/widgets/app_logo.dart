import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../core/constants/app_constants.dart';

/// Rounded app logo with a soft primary-colored shadow
class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(size * 0.23);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: SvgPicture.asset(
          AppConstants.appLogoAsset,
          fit: BoxFit.cover,
          placeholderBuilder: (context) => Container(
            color: theme.colorScheme.primary,
            child: Icon(
              Icons.menu_book_rounded,
              size: size * 0.5,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
