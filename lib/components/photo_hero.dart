import 'dart:io';

import 'package:flutter/material.dart';
import 'package:storedge/constants.dart';

class PhotoHero extends StatelessWidget {
  const PhotoHero({
    super.key,
    required this.photo,
    this.onTap,
    required this.width,
  });

  final String photo;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Hero(
        tag: "photo",
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(defaultBorderRadious * 2),
            ),
            child: Image.file(File(photo)),
          ),
        ),
      ),
    );
  }
}
