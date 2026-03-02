// lib/core/widgets/smart_image.dart

import 'dart:io';
import 'package:flutter/material.dart';

class SmartImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const SmartImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return errorWidget ?? _buildDefaultError();
    }

    final widget = _buildImageWidget();

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: widget,
      );
    }

    return widget;
  }

  Widget _buildImageWidget() {
    if (_isNetworkUrl(imageUrl!)) {
      // URL réseau → NetworkImage
      return Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? _buildDefaultPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildDefaultError();
        },
      );
    } else if (_isLocalFile(imageUrl!)) {
      // Fichier local → FileImage
      return Image.file(
        File(imageUrl!),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildDefaultError();
        },
      );
    } else {
      // Asset → AssetImage
      return Image.asset(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildDefaultError();
        },
      );
    }
  }

  bool _isNetworkUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  bool _isLocalFile(String path) {
    return path.startsWith('/') || 
           path.startsWith('file://') ||
           path.contains('/data/user/') ||
           path.contains('/storage/');
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[800],
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[900],
      child: const Icon(
        Icons.broken_image,
        color: Colors.grey,
        size: 40,
      ),
    );
  }
}