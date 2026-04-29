import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../theme/app_theme.dart';

class ModImage extends StatelessWidget {
  final String imageUrl;
  final String fallbackLetter;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ModImage({
    super.key,
    required this.imageUrl,
    this.fallbackLetter = '?',
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildPlaceholder(context);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 300),
      placeholder: (context, url) => _buildPlaceholder(context),
      errorWidget: (context, url, error) => _buildPlaceholder(context),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppTheme.cardHover,
      child: Center(
        child: Text(
          fallbackLetter.toUpperCase(),
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: (width != null && width! > 40) ? 24 : 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
