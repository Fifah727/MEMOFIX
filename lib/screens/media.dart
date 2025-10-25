import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:audioplayers/audioplayers.dart';

class NoteScreen extends StatefulWidget {
  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  File? _image;
  File? _audio;
  AudioPlayer _audioPlayer = AudioPlayer();
  final ImagePicker _picker = ImagePicker();

  // --- Ajouter image ---
  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final localPath = await _copyToLocalDir(pickedFile.path);
      setState(() => _image = File(localPath));
    }
  }

  // --- Ajouter audio ---
  Future<void> pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result != null && result.files.single.path != null) {
      final localPath = await _copyToLocalDir(result.files.single.path!);
      setState(() => _audio = File(localPath));
    }
  }

  // --- Copier fichier dans le dossier local de l'app ---
  Future<String> _copyToLocalDir(String originalPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = p.basename(originalPath);
    final newPath = '${directory.path}/$fileName';
    return File(originalPath).copy(newPath).then((file) => file.path);
  }

  // --- Supprimer fichier local ---
  Future<void> deleteFile(File? file) async {
    if (file != null && await file.exists()) {
      await file.delete();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notes avec Image et Audio")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // --- Bouton ajouter image ---
              ElevatedButton(
                onPressed: pickImage,
                child: Text("Ajouter Image"),
              ),
              if (_image != null)
                Column(
                  children: [
                    SizedBox(height: 10),
                    Image.file(_image!, height: 200, fit: BoxFit.cover),
                    TextButton(
                      onPressed: () {
                        deleteFile(_image);
                        setState(() => _image = null);
                      },
                      child: Text(
                        "Supprimer Image",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),

              SizedBox(height: 30),

              // --- Bouton ajouter audio ---
              ElevatedButton(
                onPressed: pickAudio,
                child: Text("Ajouter Audio"),
              ),
              if (_audio != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () =>
                          _audioPlayer.play(DeviceFileSource(_audio!.path)),
                    ),
                    IconButton(
                      icon: Icon(Icons.pause),
                      onPressed: () => _audioPlayer.pause(),
                    ),
                    IconButton(
                      icon: Icon(Icons.stop),
                      onPressed: () => _audioPlayer.stop(),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        deleteFile(_audio);
                        setState(() => _audio = null);
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
