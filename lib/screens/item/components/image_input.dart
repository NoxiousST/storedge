import 'dart:developer';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  final Function(File?) onImageSelected;
  final String? imagePath;

  const ImageInput({super.key, required this.onImageSelected, this.imagePath});

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  final _picker = ImagePicker();
  File? _selectedImage;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return SizedBox(
                height: 160,
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              padding: const EdgeInsets.all(12),
                              iconSize: 36,
                              onPressed: () async {
                                XFile? image = await _picker.pickImage(source: ImageSource.camera);
                                if (image != null) {
                                  setState(() {
                                    _selectedImage = File(image.path);
                                    widget.onImageSelected(_selectedImage);
                                  });
                                  Navigator.pop(context);
                                }
                              },
                              icon: const Icon(Icons.camera_alt_rounded),
                            ),
                            const Text("Camera")
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              padding: const EdgeInsets.all(12),
                              iconSize: 36,
                              onPressed: () async {
                                XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                                if (image != null) {
                                  setState(() {
                                    _selectedImage = File(image.path);
                                    widget.onImageSelected(_selectedImage);
                                  });
                                  Navigator.pop(context);
                                }
                              },
                              icon: const Icon(Icons.collections_rounded),
                            ),
                            const Text("Gallery")
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });
      },
      child: DottedBorder(
        borderType: BorderType.RRect,
        dashPattern: const [6, 3, 2, 3],
        color: Colors.indigo,
        radius: const Radius.circular(12),
        child: ClipRRect(
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _selectedImage != null
                ? Image.file(
                    _selectedImage!,
                    width: 200.0,
                    height: 200.0,
                    fit: BoxFit.fitHeight,
                  )
                : (widget.imagePath != null
                    ? Image.file(
                        File(widget.imagePath!),
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.fitHeight,
                      )
                    : SizedBox(
                        width: 200,
                        height: 200,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.grey[800],
                        ),
                      )),
          ),
        ),
      ),
    );
  }
}
