import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageStorageTestScreen extends StatefulWidget {
  const ImageStorageTestScreen({super.key});

  @override
  State<ImageStorageTestScreen> createState() => _ImageStorageTestScreenState();
}

class _ImageStorageTestScreenState extends State<ImageStorageTestScreen> {
  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveImage() async {
    if (_imageFile == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.png';
    final savedImage = await _imageFile!.copy('${appDir.path}/$fileName');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image sauvegardée dans ${savedImage.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test stockage image')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _imageFile == null
                ? const Text('Aucune image sélectionnée.')
                : Image.file(
                    _imageFile!,
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Choisir une image'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveImage,
              child: const Text('Sauvegarder l\'image'),
            ),
          ],
        ),
      ),
    );
  }
}
