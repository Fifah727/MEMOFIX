import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;

class SpotifyMetadataScreen extends StatefulWidget {
  @override
  _SpotifyMetadataScreenState createState() => _SpotifyMetadataScreenState();
}

class _SpotifyMetadataScreenState extends State<SpotifyMetadataScreen> {
  final TextEditingController _urlController = TextEditingController();
  Map<String, dynamic>? _trackData;
  bool _isLoading = false;
  String? _error;

  // Vous devez remplacer ces valeurs par vos vraies clés API Spotify
  final String clientId = 'd1a8664b41414db9afb0f63e064a2c9b';
  final String clientSecret = '1ce590dcbfdf425fb14bbf246842d259';

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

  Future<String> _getAccessToken() async {
    final String credentials = base64Encode(
      utf8.encode('$clientId:$clientSecret'),
    );

    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['access_token'];
    } else {
      throw Exception('Erreur lors de l\'authentification');
    }
  }

  String _extractTrackId(String url) {
    // Extrait l'ID de la track depuis l'URL Spotify
    final regex = RegExp(r'track\/([a-zA-Z0-9]+)');
    final match = regex.firstMatch(url);
    if (match != null) {
      return match.group(1)!;
    }
    throw Exception('URL Spotify invalide');
  }

  Future<void> _fetchTrackMetadata() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _trackData = null;
    });

    try {
      final trackId = _extractTrackId(_urlController.text);
      final accessToken = await _getAccessToken();

      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/tracks/$trackId'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Récupération des genres depuis l'artiste
        final artistId = data['artists'][0]['id'];
        final artistResponse = await http.get(
          Uri.parse('https://api.spotify.com/v1/artists/$artistId'),
          headers: {'Authorization': 'Bearer $accessToken'},
        );

        List<String> genres = [];
        if (artistResponse.statusCode == 200) {
          final artistData = json.decode(artistResponse.body);
          genres = List<String>.from(artistData['genres'] ?? []);
        }

        setState(() {
          _trackData = {
            'name': data['name'],
            'artists': data['artists']
                .map((artist) => artist['name'])
                .join(', '),
            'album': data['album']['name'],
            'release_date': data['album']['release_date'],
            'duration_ms': data['duration_ms'],
            'image': data['album']['images'].isNotEmpty
                ? data['album']['images'][0]['url']
                : null,
            'genres': genres,
          };
        });
      } else {
        throw Exception('Erreur lors de la récupération des données');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveMetadataAsMP3() async {
    if (_trackData == null) return;

    // Demander permission de stockage
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      setState(() {
        _error = 'Permission de stockage refusée';
      });
      return;
    }

    try {
      // Créer un MP3 vide avec métadonnées ID3
      final mp3Data = _createEmptyMP3WithMetadata(_trackData!);

      // Sauvegarder le fichier
      // final directory = await getExternalStorageDirectory();
      final fileName = '${_trackData!['name']}_${_trackData!['artists']}.mp3'
          .replaceAll(RegExp(r'[^\w\s-.]'), ''); // Nettoyer le nom
      final savePath = await _getSavePath(fileName);
      final file = File('${savePath}');

      await file.writeAsBytes(mp3Data);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('MP3 avec métadonnées sauvegardé: $fileName'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de la sauvegarde: $e';
      });
    }
  }

  Uint8List _createEmptyMP3WithMetadata(Map<String, dynamic> trackData) {
    // En-tête MP3 minimal (sera silencieux)
    final mp3Header = [
      0xFF, 0xFB, 0x90, 0x00, // En-tête MP3
      // Suivi de données audio vides/silencieuses
      ...List.filled(1000, 0x00), // 1KB de silence
    ];

    // Tag ID3v2 avec métadonnées
    final id3Tag = _createID3v2Tag(trackData);

    // Combiner ID3 + MP3
    return Uint8List.fromList([...id3Tag, ...mp3Header]);
  }

  List<int> _createID3v2Tag(Map<String, dynamic> trackData) {
    List<int> frames = [];

    // Frame TIT2 (Titre)
    frames.addAll(_createID3Frame('TIT2', trackData['name']));

    // Frame TPE1 (Artiste)
    frames.addAll(_createID3Frame('TPE1', trackData['artists']));

    // Frame TALB (Album)
    frames.addAll(_createID3Frame('TALB', trackData['album']));

    // Frame TYER (Année)
    if (trackData['release_date'] != null) {
      final year = trackData['release_date'].substring(0, 4);
      frames.addAll(_createID3Frame('TYER', year));
    }

    // Frame TCON (Genre)
    if (trackData['genres'].isNotEmpty) {
      frames.addAll(_createID3Frame('TCON', trackData['genres'][0]));
    }

    // En-tête ID3v2
    final header = [
      0x49, 0x44, 0x33, // "ID3"
      0x03, 0x00, // Version 2.3
      0x00, // Flags
      // Taille (synchsafe integer)
      ..._toSynchsafeInt(frames.length),
    ];

    return [...header, ...frames];
  }

  List<int> _createID3Frame(String frameId, String content) {
    final contentBytes = utf8.encode(content);
    final frameHeader = [
      ...utf8.encode(frameId), // ID du frame (4 bytes)
      ..._toInt32(contentBytes.length + 1), // Taille + 1 pour encoding
      0x00, 0x00, // Flags
      0x00, // Text encoding (ISO-8859-1)
    ];

    return [...frameHeader, ...contentBytes];
  }

  List<int> _toInt32(int value) {
    return [
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF,
    ];
  }

  List<int> _toSynchsafeInt(int value) {
    return [
      (value >> 21) & 0x7F,
      (value >> 14) & 0x7F,
      (value >> 7) & 0x7F,
      value & 0x7F,
    ];
  }

  String _formatDuration(int durationMs) {
    final duration = Duration(milliseconds: durationMs);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Extracteur Spotify'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        labelText: 'Lien Spotify',
                        hintText: 'https://open.spotify.com/track/...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _fetchTrackMetadata,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Extraire les métadonnées'),
                    ),
                    if (_trackData != null) ...[
                      SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _saveMetadataAsMP3,
                        icon: Icon(Icons.save),
                        label: Text('Sauver en MP3'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_error != null)
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Erreur: $_error',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
              ),
            if (_trackData != null)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_trackData!['image'] != null)
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _trackData!['image'],
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        SizedBox(height: 16),
                        _buildInfoRow('Titre', _trackData!['name']),
                        _buildInfoRow('Artiste(s)', _trackData!['artists']),
                        _buildInfoRow('Album', _trackData!['album']),
                        _buildInfoRow(
                          'Date de sortie',
                          _trackData!['release_date'],
                        ),
                        _buildInfoRow(
                          'Durée',
                          _formatDuration(_trackData!['duration_ms']),
                        ),
                        if (_trackData!['genres'].isNotEmpty)
                          _buildInfoRow(
                            'Genres',
                            _trackData!['genres'].join(', '),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}

// Widget principal pour tester
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify Metadata Extractor',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SpotifyMetadataScreen(),
    );
  }
}

void main() {
  runApp(MyApp());
}
