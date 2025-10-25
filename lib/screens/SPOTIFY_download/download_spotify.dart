// file: lib/screens/download_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'fast_download.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({Key? key}) : super(key: key);

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isDownloading = false;
  double _progress = 0.0;
  CancelToken? _cancelToken;

  @override
  void dispose() {
    _urlController.dispose();
    _cancelToken?.cancel();
    super.dispose();
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status.isGranted) return true;
      final result = await Permission.storage.request();
      return result.isGranted;
    }
    // iOS: no runtime storage permission needed for app directories
    return true;
  }

  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }

  Future<String> _getSavePath(String filename) async {
    final downloadsDir = Directory(
      '/storage/emulated/0/Download/Musique_Spotify',
    );
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    String filePath = p.join(downloadsDir.path, filename);
    File file = File(filePath);
    int counter = 1;

    while (await file.exists()) {
      final name = p.basenameWithoutExtension(filename);
      final ext = p.extension(filename);
      filePath = p.join(downloadsDir.path, '${name}_$counter$ext');
      file = File(filePath);
      counter++;
    }
    return filePath;
  }

  Future<void> _downloadFile(String url) async {
    if (!_isValidUrl(url)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('❌ URL invalide')));
      return;
    }

    final ok = await _requestStoragePermission();
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission de stockage refusée')),
      );
      return;
    }

    final uri = Uri.parse(url);
    String filename = p.basename(uri.path).isNotEmpty
        ? p.basename(uri.path)
        : 'audio_${DateTime.now().millisecondsSinceEpoch}.mp3';

    String savePath = await _getSavePath(filename);
    int i = 1;
    while (await File(savePath).exists()) {
      final nameWithoutExt = p.basenameWithoutExtension(filename);
      final ext = p.extension(filename);
      filename = "${nameWithoutExt}_$i$ext";
      savePath = await _getSavePath(filename);
      i++;
    }

    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _cancelToken = CancelToken();
    });

    try {
      final downloader = FastDownloader(
        onProgress: (progress) {
          setState(() {
            _progress = progress;
          });
        },
      );

      await downloader.downloadFile(
        url,
        savePath,
        parts: 4,
        cancelToken: _cancelToken,
      );

      setState(() {
        _isDownloading = false;
        _progress = 0.0;
        _cancelToken = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Téléchargé dans : $savePath'),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      for (int j = 0; j < 4; j++) {
        final tempFile = File("$savePath.part$j");
        if (await tempFile.exists()) await tempFile.delete();
      }

      setState(() {
        _isDownloading = false;
        _progress = 0.0;
        _cancelToken = null;
      });

      String message;
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.connectionTimeout:
          case DioErrorType.sendTimeout:
          case DioErrorType.receiveTimeout:
            message = "Temps de connexion dépassé";
            break;
          case DioErrorType.badResponse:
            message = "Erreur serveur : ${e.response?.statusCode}";
            break;
          case DioErrorType.cancel:
            message = "Téléchargement annulé";
            break;
          case DioErrorType.connectionError:
            message = "Pas de connexion Internet";
            break;
          default:
            message = "Erreur inconnue: ${e.message}";
        }
      } else {
        message = "Erreur: $e";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _onStartDownload() {
    final url = _urlController.text.trim();
    _downloadFile(url);
  }

  void _onCancel() {
    _cancelToken?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Télécharger une musique'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input
            TextField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                hintText: 'Colle le lien http(s) de ta musique',
                labelText: 'Lien de la musique',
                prefixIcon: const Icon(Icons.link),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _urlController.clear(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isDownloading ? null : _onStartDownload,
                    icon: const Icon(Icons.download),
                    label: const Text('Télécharger'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (_isDownloading)
                  ElevatedButton.icon(
                    onPressed: _onCancel,
                    icon: const Icon(Icons.cancel),
                    label: const Text('Annuler'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress
            if (_isDownloading)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Progress: ${(_progress * 100).toStringAsFixed(0)} %'),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(value: _progress),
                ],
              ),
            const Spacer(),
            // Small help text
            Text(
              'La musique est sauvegardée dans le dossier de l\'application (ou Download si disponible).',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
