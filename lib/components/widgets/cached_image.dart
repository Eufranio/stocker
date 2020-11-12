import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {

  final Uint8List imageData;
  final File imageFile;
  final String imageUrl;
  final double height;
  final double width;
  final double defaultImageHeight;

  CachedImage({this.imageFile, this.imageData, this.imageUrl, this.height, this.width, this.defaultImageHeight = 150});

  @override
  Widget build(BuildContext context) {
    if (imageData != null)
      return Image.memory(imageData);
    if (imageFile != null)
      return Image.file(imageFile);
    if (imageUrl == null)
      return FlutterLogo(size: defaultImageHeight);
    return CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: width,
        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => Icon(Icons.error)
    );
  }
}