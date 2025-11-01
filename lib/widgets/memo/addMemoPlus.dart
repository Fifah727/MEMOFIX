import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:line_icons/line_icons.dart';
import 'package:memofix/models/MemoItem.dart';
import 'package:memofix/services/query/memo/memo_service.dart';
import 'package:memofix/models/CategorieItem.dart';
import 'package:memofix/services/query/categorie_service.dart';
import 'package:memofix/models/ImageItem.dart';
import 'package:memofix/services/query/memo/image_service.dart';
import 'package:memofix/models/AudioItem.dart';
import 'package:memofix/services/query/memo/audio_service.dart';

import 'imagePreviewScreen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:memofix/models/TacheItem.dart';
import 'package:memofix/services/query/memo/tache_service.dart';

import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:math'; // Pour sin, cos et les calculs mathématiques
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddMemoPlus extends StatefulWidget {
  final MemoItem memo;

  const AddMemoPlus({super.key, required this.memo});

  @override
  State<AddMemoPlus> createState() => _AddMemoPlusState();
}

class _AddMemoPlusState extends State<AddMemoPlus>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final MemoService memoService = MemoService();
  final CategorieService categorieService = CategorieService();
  final ImageService imageService = ImageService();
  final TacheService tacheService = TacheService();
  final AudioService audioService = AudioService();

  late TextEditingController _titleController;
  late TextEditingController _textController;
  TacheItem? _tacheEnEdition;
  final _champTachecontroller = TextEditingController();

  String _selectedCategory = "Travail";
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];
  late bool verouiller;

  // AUDIO MEMO
  final _recorder = AudioRecorder();
  AudioPlayer _player = AudioPlayer();
  final AudioService _audioService = AudioService();
  bool _isRecording = false;
  String? _recordedPath;
  AudioItem? _audioItem;
  bool _isPlaying = false;
  bool _isPaused = false;

  String _getMonth(int month) {
    final months = {
      1: 'JAN',
      2: 'FÉV',
      3: 'MAR',
      4: 'AVR',
      5: 'MAI',
      6: 'JUI',
      7: 'JUI',
      8: 'AOÛ',
      9: 'SEP',
      10: 'OCT',
      11: 'NOV',
      12: 'DÉC',
    };
    return months[month] ?? '$month';
  }

  String _formatDateCool(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dt.year, dt.month, dt.day);

    // Heure et minutes avec padding
    final hourMinute =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    if (date == today) return "Aujourd'hui à $hourMinute";
    if (date == yesterday) return "Hier à $hourMinute";

    // Autres dates → dd MMM à HH:mm
    return "${dt.day} ${_getMonth(dt.month)} à $hourMinute";
  }

  // Charger l'audio existant depuis la BD si id != 0
  Future<void> _loadAudio() async {
    if (widget.memo.id == 0) return; // pas de BD pour id 0
    final audio = await _audioService.getSingleAudioByMemo(widget.memo.id);
    setState(() {
      _audioItem = audio;
      _recordedPath = audio?.nom;
    });
  }

  // Demande permission micro
  Future<bool> _requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  // Commencer enregistrement
  Future<void> startRecording() async {
    if (_isRecording) return;

    final hasPermission = await _requestMicPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez accepter la permission de l'utilisation du microphone pour l'enregistrement vocaux",
          ),
        ),
      );
      return;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${appDir.path}/memos_audios');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }

    final filePath = "${audioDir.path}/memo_${widget.memo.id}.m4a";

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: filePath,
    );

    _animationController.repeat();
    setState(() {
      _isRecording = true;
      _recordedPath = filePath; // toujours disponible pour play/pause
    });
  }

  // Arrêter l'enregistrement
  Future<void> stopRecording() async {
    if (!_isRecording) return;
    final path = await _recorder.stop();
    //
    _animationController.stop();
    setState(() => _isRecording = false);

    if (path != null) {
      // 🔹 Si id != 0 → sauvegarde BD
      if (widget.memo.id != 0) {
        await _audioService.supprimerAudioByMemo(widget.memo.id);
        print("1 - Audio ajouter par MODIF Memo : dans BD");
        await _audioService.ajouterAudio(
          AudioItem(nom: path, id_memo: widget.memo.id),
        );
        print("2 - Audio ajouter par MODIF Memo : dans appData");
        await _player.setFilePath(path);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enregistrement sauvegardé")),
        );
      }

      // Préparer player pour lecture
      await _player.stop();

      setState(() => _recordedPath = path);
    }
  }

  // Jouer / pause l'audio
  Future<void> playRecording() async {
    if (_recordedPath == null) return;

    if (_isPlaying) {
      _animationController.repeat();
      await _player.pause();
      setState(() {
        _isPaused = true;
        _isPlaying = false;
      });
      return;
    }

    if (_isPaused) {
      await _player.play();
      _animationController.stop();
      setState(() {
        _isPaused = false;
        _isPlaying = true;
      });
      return;
    }

    // Démarrer depuis le début
    await _player.setFilePath(_recordedPath!);
    await _player.play();
    setState(() => _isPlaying = true);
  }

  // Supprimer l'audio
  Future<void> deleteRecording() async {
    if (_recordedPath == null) return;

    await _player.pause();

    // 🔹 Supprimer en BD seulement si id != 0
    if (widget.memo.id != 0) {
      print("Supp Audio effectuer par Modification du memo");
      await _audioService.supprimerAudioByMemo(widget.memo.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enregistrement supprimé")));
    }

    setState(() {
      _recordedPath = null;
      _audioItem = null;
    });
  }

  Future<void> saveAudioAfterMemoCreation(int id_new_memo) async {
    if (_recordedPath != null && widget.memo.id == 0) {
      print("Ajout du audio du nouveau mémo en cours...");

      try {
        final file = File(_recordedPath!);

        if (await file.exists()) {
          // 1️⃣ Créer le dossier si besoin
          final appDir = await getApplicationDocumentsDirectory();
          final audioDir = Directory('${appDir.path}/memos_audios');
          if (!await audioDir.exists()) {
            await audioDir.create(recursive: true);
          }

          // 2️⃣ Construire le nouveau chemin correct (avec le vrai id)
          final newPath = "${audioDir.path}/memo_${id_new_memo}.m4a";

          // 3️⃣ Copier le fichier vers le nouveau nom
          await file.copy(newPath);
          print("1 - Audio copié vers : $newPath");

          // 4️⃣ Ajouter l’audio dans la base de données
          await _audioService.ajouterAudio(
            AudioItem(nom: newPath, id_memo: id_new_memo),
          );
          print("2 - Audio ajouté en base avec id_memo: $id_new_memo");

          // 5️⃣ Supprimer l’ancien fichier temporaire (memo_0.m4a)
          await _audioService.deleteAudio(_recordedPath!);
          print("3 - Ancien fichier supprimé : ${_recordedPath!}");

          // 6️⃣ Mettre à jour le chemin actuel dans la mémoire
          _recordedPath = newPath;
        } else {
          print("⚠️ Audio introuvable à $_recordedPath");
        }
      } catch (e) {
        debugPrint("Erreur lors de l’ajout de l’audio du nouveau mémo : $e");
      }
    }
  }

  // AUDIO MEMO FIN

  @override
  void dispose() {
    _stopAudioProperly();
    _recorder.dispose();
    _player.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _stopAudioProperly() async {
    try {
      if (_player.playing) {
        await _player
            .stop(); // ou .pause() si tu veux juste stopper sans réinitialiser
      }
    } catch (e) {
      debugPrint("Erreur arrêt audio : $e");
    }

    if (mounted) {
      setState(() {
        _isPaused = true;
        _isPlaying = false;
      });
    }
  }

  List<ImageItem> _imagesNom = [];
  List<ImageItem> _imagesNomInitial = [];

  bool tache = false;
  bool imgPick = false;
  bool audio = false;
  late List<TacheItem> _taches;
  late List<TacheItem> _tachesAncien;

  Future<void> loadTaches() async {
    try {
      final cats = await tacheService.getTachesByMemo(widget.memo.id);
      setState(() {
        _taches = cats;
        _tachesAncien = cats
            .map(
              (t) => TacheItem(
                id: t.id,
                id_memo: t.id_memo,
                contenu: t.contenu,
                fait: t.fait,
                createdAt: t.createdAt,
              ),
            )
            .toList();
      });
    } catch (e) {
      debugPrint("Erreur lors du chargement des taches : $e");
    }
  }

  void ajoutChampTache() {
    if (_champTachecontroller.text.trim().isNotEmpty) {
      setState(() {
        _taches.add(
          TacheItem(
            contenu: _champTachecontroller.text.trim(),
            fait: false,
            createdAt: DateTime.now(),
          ),
        );

        _tacheEnEdition = null;
        _champTachecontroller.clear();

        FocusScope.of(context).unfocus(); // ✅ ferme le clavier
      });
    }
  }

  @override
  void initState() {
    super.initState();
    //
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    //
    loadCategories();
    loadImgs();
    _taches = [];

    if (widget.memo.id != 0) {
      _loadAudio();
      loadTaches();
    } else {
      _taches.clear();
    }
    //
    verouiller = widget.memo.verrouille;
    _titleController = TextEditingController(text: widget.memo.titre);
    _textController = TextEditingController(text: widget.memo.text);

    _titleController.addListener(() {
      setState(() {}); // rebuild pour recalculer _canEnreg()
    });

    _textController.addListener(() {
      setState(() {}); // rebuild pour recalculer _canEnreg()
    });

    _player = AudioPlayer();

    // 🔁 Écoute en temps réel de l’état du player
    _player.playerStateStream.listen((state) {
      final playing = state.playing;
      final completed = state.processingState == ProcessingState.completed;

      if (completed) {
        _player.seek(Duration.zero);
        _player.pause();
        setState(() {
          _isPlaying = false;
          _isPaused = false;
        });
      } else {
        setState(() {
          _isPlaying = playing;
          _isPaused =
              !playing && state.processingState == ProcessingState.ready;
        });
      }
    });
  }

  Future<void> copyAllImagesToAppDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final memoImageDir = Directory('${appDir.path}/memos_images');

    if (!(await memoImageDir.exists())) {
      await memoImageDir.create(recursive: true);
    } else {
      print('Dossier memos_images déjà existant');
    }

    for (int i = 0; i < _imagesNom.length; i++) {
      final imageItem = _imagesNom[i];
      final originalPath = imageItem.nom_img;
      final originalFile = File(originalPath);

      if (await originalFile.exists()) {
        // Vérifie si le fichier est déjà dans memos_images
        if (!originalPath.startsWith(memoImageDir.path)) {
          final newFileName =
              '${DateTime.now().millisecondsSinceEpoch}_${originalFile.path.split('/').last}';
          final savedPath = '${memoImageDir.path}/$newFileName';
          final savedImage = await originalFile.copy(savedPath);

          // Mettre à jour la liste
          _imagesNom[i] = ImageItem(
            id: imageItem.id,
            nom_img: savedImage.path,
            date_ajout: imageItem.date_ajout,
            id_memo: imageItem.id_memo,
          );
        } else {
          print('Fichier déjà dans memos_images, copie ignorée');
        }
      } else {
        print('Fichier original introuvable : $originalPath');
      }
    }
  }

  // retourne chemin ou nom image, dans base de donnees
  Future<void> loadImgs() async {
    try {
      // 1️⃣ Charger les ImageItem depuis la BD
      final cats = await imageService.getImagesByMemo(widget.memo.id);

      // 2️⃣ Créer la liste de XFile
      final List<XFile> xFiles = [];
      for (final img in cats) {
        final fileImg = File(img.nom_img); // chemin complet déjà dans nom_img
        if (await fileImg.exists()) {
          xFiles.add(XFile(fileImg.path));
        } else {
          debugPrint('Image non trouvée : ${img.nom_img}');
        }
      }

      setState(() {
        _imagesNomInitial = List<ImageItem>.from(cats);
        _imagesNom = List<ImageItem>.from(cats);
        _images = xFiles;
      });
    } catch (e) {
      debugPrint("Erreur lors du chargement des images du memo : $e");
    }
  }

  List<CategorieItem> _categories = [];
  Future<void> loadCategories() async {
    try {
      final cats = await categorieService.getCategories();

      // Sécurité : vérifie que widget.memo.category est non null
      final selectedCat = widget.memo.category != null
          ? cats
                .firstWhere(
                  (a) => a.id_c == widget.memo.category,
                  orElse: () => CategorieItem(id_c: 0, nom_c: ''),
                )
                .nom_c
          : '';

      setState(() {
        _categories = cats;
        _selectedCategory = selectedCat;
      });
    } catch (e) {
      debugPrint("Erreur lors du chargement des categories : $e");
    }
  }

  int _getCategoryByNom(String? nomCategory) {
    // getAllCategorie
    final cat = _categories.firstWhere(
      (a) => a.nom_c == nomCategory,
      orElse: () => CategorieItem(id_c: 0, nom_c: ''), // sécurité
    );
    return cat.id_c;
  }

  String _getCategoryById(int? idCategory) {
    // getAllCategorie
    final cat = _categories.firstWhere(
      (a) => a.id_c == idCategory,
      orElse: () => CategorieItem(id_c: 0, nom_c: ''), // sécurité
    );
    return cat.nom_c;
  }

  bool _canEnreg() {
    final titreInput = _titleController.text.trim();
    final text = _textController.text.trim();

    if (titreInput.isEmpty && text.isEmpty) {
      return false;
    } else
      return true;
  }

  void _appliquerChangementTache() async {
    final contenu = _champTachecontroller.text.trim();
    if (contenu.isEmpty) return;

    // ici on va juste mettre a jour _taches
    // pas appliquer au BD

    if (_tacheEnEdition != null) {
      // Modification existante dans _taches
      _tacheEnEdition!.contenu = contenu;
      setState(() {
        _tacheEnEdition = null;
        _champTachecontroller.clear();
      });
    } else {
      // Ajouter nouvelle tâche dans _taches
      ajoutChampTache();
    }
  }

  void suppLocal(TacheItem task) {
    // Supprimer la liste locale _taches
    setState(() {
      _taches.removeWhere((t) => t == task);
    });
  }

  void _enregMemo() async {
    // modif
    final titreInput = _titleController.text.trim();
    final text = _textController.text.trim();

    if (titreInput.isEmpty && text.isEmpty) {
      return;
    } else {
      String titre;
      if (titreInput.isEmpty) {
        final premierMot = text.split(RegExp(r'\s+')).first;
        titre = premierMot.length > 30
            ? '${premierMot.substring(0, 20)}...'
            : premierMot;
      } else {
        titre = titreInput;
      }

      // modif
      if (widget.memo.id != 0) {
        final updatedMemo = MemoItem(
          id: widget.memo.id,
          titre: titre,
          text: text,
          verrouille: verouiller,
          category: _getCategoryByNom(_selectedCategory),
          createdAt: widget.memo.createdAt,
          modifiedAt: widget.memo.modifiedAt,
          isImportant: widget.memo.isImportant,
        );
        try {
          await memoService.modifMemo(updatedMemo);

          // 1 - modif aussi images : ajou, supp
          final imagesAAjouter = _imagesNom
              .where(
                (img) =>
                    !_imagesNomInitial.any((old) => old.nom_img == img.nom_img),
              )
              .toList();
          final imagesASupprimer = _imagesNomInitial
              .where(
                (old) => !_imagesNom.any((img) => img.nom_img == old.nom_img),
              )
              .toList();
          // SUPP
          for (final img in imagesASupprimer) {
            // Supprimer dans appData
            try {
              final file = File(img.nom_img);
              if (await file.exists()) await file.delete();
            } catch (e) {
              debugPrint('Erreur suppression image: $e');
            }
            // Supprimer en base
            await imageService.supprimerImgByMemo(img.id_memo);
          }
          // AJOUT
          final appDir = await getApplicationDocumentsDirectory();
          final memoImageDir = Directory('${appDir.path}/memos_images');
          if (!(await memoImageDir.exists())) {
            await memoImageDir.create(recursive: true);
          }
          for (final img in imagesAAjouter) {
            // appData : ajout
            final fileName =
                '${DateTime.now().millisecondsSinceEpoch}_${img.nom_img.split('/').last}';
            final savedImage = await File(
              img.nom_img,
            ).copy('${appDir.path}/memos_images/$fileName');

            final newImageItem = ImageItem(
              nom_img: savedImage.path,
              date_ajout: DateTime.now(),
              id_memo: widget.memo.id,
            );

            // Bd : ajout
            await imageService.ajouterImg(newImageItem);

            // Mettre à jour la liste locale
            _imagesNom.add(newImageItem);
          }

          // 2 - TACHE MODIF : synchro
          // Tâches à ajouter (nouveau id == 0)
          final tachesAjouter = _taches.where((t) => t.id_memo == 0).toList();

          // Tâches existantes à modifier (id != 0 et fait/contenu modifié)
          final tachesModifier = _taches.where((t) {
            if (t.id_memo == 0) return false; // nouvelle tâche, pas à modifier
            final old = _tachesAncien.firstWhere(
              (o) => o.id_memo == t.id_memo,
              orElse: () => TacheItem(
                id_memo: -1,
                contenu: '',
                fait: false,
                createdAt: DateTime.now(),
              ),
            );
            return old.id_memo != -1 &&
                (old.fait != t.fait || old.contenu != t.contenu);
          }).toList();
          // Tâches à supprimer ( id_ancien != id_nouveau)
          final tachesSupprimer = _tachesAncien
              .where(
                (old) => old.id != 0 && !_taches.any((t) => t.id == old.id),
              )
              .toList();

          // SUPPRESSION
          for (final task in tachesSupprimer) {
            await tacheService.supprimerTache(task.id); // <- id unique !
          }
          // AJOUT
          for (final t in tachesAjouter) {
            final task = TacheItem(
              contenu: t.contenu,
              createdAt: DateTime.now(),
              id_memo: widget.memo.id,
              fait: t.fait,
            );
            await tacheService.ajouterTache(task);
          }
          // MODIFICATION
          for (final t in tachesModifier) {
            await tacheService.modifTache(t);
          }

          // retourner a memoList
          Navigator.pushReplacementNamed(context, '/memo');
        } catch (e) {
          debugPrint("Erreur lors de la creation du memo : $e");
        }
      } else {
        print("Ajout Memo en cours...");
        // ajout
        final newmemo = MemoItem(
          titre: titre,
          text: text,
          verrouille: verouiller,
          category: _getCategoryByNom(_selectedCategory),
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now(),
          isImportant: false,
        );
        try {
          final id_new_memo = await memoService.ajouterMemo(newmemo);
          if (id_new_memo != null) {
            // 🔹 Sauvegarder audio si existant et id initial == 0
            await saveAudioAfterMemoCreation(id_new_memo);
            // 1 - ajout Image
            // appData : Copier les images dans appData
            await copyAllImagesToAppDir();
            // Mettre à jour id_memo de chaque ImageItem
            for (int i = 0; i < _imagesNom.length; i++) {
              final oldImage = _imagesNom[i];
              _imagesNom[i] = ImageItem(
                id: oldImage.id,
                nom_img: oldImage.nom_img,
                date_ajout: oldImage.date_ajout,
                id_memo: id_new_memo,
              );
            }
            // BD : Ajouter les images en BD
            for (final imageItem in _imagesNom) {
              await imageService.ajouterImg(imageItem);
            }
            // 2 - ajout tache : BD
            // mettre a jour id_memo dans chaque tache
            for (int i = 0; i < _taches.length; i++) {
              final oldTache = _taches[i];
              _taches[i] = TacheItem(
                id: oldTache.id,
                contenu: oldTache.contenu,
                createdAt: oldTache.createdAt,
                id_memo: id_new_memo,
                fait: oldTache.fait,
              );
            }
            for (final tacheItem in _taches) {
              await tacheService.ajouterTache(tacheItem);
            }
            _taches.clear();
            // retour liste
            Navigator.pushReplacementNamed(context, '/memo');
          } else
            print("Erreur lors de creation du memo");
        } catch (e) {
          debugPrint("Erreur lors de la creation du memo : $e");
        }
      }

      _stopAudioProperly();
    }

    //
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'travail': const Color(0xFF1E3A8A), // bleu nuit foncé
      'personnel': const Color(0xFF6B8E23), // vert matcha
      'idée': const Color(0xFF4B0082), // violet profond
      'tâche': const Color(0xFF734100), // brun foncé
      'musique': const Color(0xFF8B005D), // rose foncé / prune
      'voyage': const Color(0xFF2E2E2C), // gris anthracite
    };

    return colors[category.toLowerCase()] ??
        Color.fromRGBO(
          (category.hashCode & 0xFF0000) >> 16,
          (category.hashCode & 0x00FF00) >> 8,
          (category.hashCode & 0x0000FF),
          1.0,
        );
  }

  // Définir un icône par catégorie
  IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'travail':
        return Icons.work_outline;
      case 'personnel':
        return Icons.person_outline;
      case 'idée':
        return Icons.lightbulb_outline;
      case 'tâche':
        return Icons.check_circle_outline;
      case 'musique':
        return Icons.music_note;
      case 'voyage':
        return Icons.flight_takeoff;
      default:
        return Icons.label_outline;
    }
  }

  // ajouter image dans le memo : voyage, music
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // CHEMIN COMPLET du fichier temporaire
      final originalPath = pickedFile.path;

      // Créer un nouvel objet ImageItem
      final newImage = ImageItem(
        nom_img: originalPath, // <-- chemin complet
        date_ajout: DateTime.now(),
        id_memo: widget.memo.id ?? 0,
      );

      // Ajouter à la liste
      setState(() {
        _imagesNom.add(newImage);
        _images.add(pickedFile);
      });

      print('🟢 Image ajoutée : $originalPath');
    }
  }

  // Supprimer une image
  void _removeImage(int index) {
    setState(() {
      _imagesNom.removeAt(index);
      _images.removeAt(index);
    });
  }

  // fonction
  void _execute(BuildContext context, String media) {
    setState(() {
      switch (media) {
        case 'liste':
          tache = !tache;
          audio = false;
          break;
        case 'image':
          imgPick = !imgPick;
          break;
        case 'audio':
        case 'musique':
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (_) => AudioMemoScreen(idMemo: widget.memo.id),
          //   ),
          // );
          tache = false;
          audio = !audio;
          break;
        case 'personnel':
          verouiller = !verouiller;
          break;
      }
    });
  }

  Widget _navItem(IconData icon, String key) {
    final color = _getCategoryColor(key);

    // ✅ Déterminer si cet item est actif selon son booléen
    final isActive = switch (key) {
      'liste' => tache,
      'audio' => audio,
      'musique' => audio,
      'image' => imgPick,
      'personnel' => verouiller,
      _ => false,
    };

    return GestureDetector(
      onTap: () => _execute(context, key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          // color: isActive ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 26,
              color: isActive
                  ? color
                  : const Color.fromARGB(255, 110, 110, 110),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(_selectedCategory);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFFAFAFA),
        title: Text(
          widget.memo.id == 0 ? 'Nouveau Mémo' : "Modification",
          style: TextStyle(fontSize: 20, color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(LineIcons.arrowLeft, color: Colors.black87),
          onPressed: (() async {
            // seulement si on retourne ou quitte le screen sans enregistrer
            // on supprime le audio temporaire memo_0
            if (widget.memo.id == 0 && _recordedPath != null) {
              await _audioService.deleteAudio(_recordedPath!);
            }

            // stopper la lecture du audio si en cours
            _stopAudioProperly();
            Navigator.pushNamed(context, '/memo');
          }),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 12.0,
            ), // espace par rapport au bord
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: _canEnreg() ? _enregMemo : null,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _canEnreg()
                      ? theme.primaryColor.withOpacity(0.1) // léger fond coloré
                      : Colors.grey.withOpacity(0.1),
                ),
                padding: const EdgeInsets.all(6), // taille du bouton
                child: Icon(
                  LineIcons.check,
                  color: _canEnreg() ? theme.primaryColor : Colors.grey,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),

      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Champ titre
            Text(
              widget.memo.id == 0
                  ? "Aujourd'hui"
                  : _formatDateCool(widget.memo.createdAt),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 109, 109, 109),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              onSubmitted: ((_) {
                FocusScope.of(context).unfocus();
              }),
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w500,
                color: Color(0xFF353535),
              ),
              cursorColor: color,
              decoration: const InputDecoration(
                border: InputBorder.none, // pas de border
                enabledBorder:
                    InputBorder.none, // pas de border quand désactivé
                focusedBorder: InputBorder.none, // pas de border quand focus
                hintText: "Titre...",
                hintStyle: TextStyle(color: Color.fromARGB(255, 80, 80, 80)),
                filled: false,
                isDense: true, // réduit la hauteur interne
                contentPadding: EdgeInsets.zero, // supprime padding interne
              ),
            ),
            const SizedBox(height: 20),

            // categorie
            Wrap(
              spacing: 8,
              children: _categories.map((cat) {
                final selected = _selectedCategory == cat.nom_c;
                final catColor = _getCategoryColor(cat.nom_c);

                return ChoiceChip(
                  avatar: Icon(
                    getCategoryIcon(cat.nom_c),
                    color: selected ? Colors.white : Colors.grey.shade700,
                    size: 20,
                  ),
                  label: Text(
                    cat.nom_c,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: selected,
                  showCheckmark: false,
                  selectedColor: catColor,
                  backgroundColor: Colors.grey.shade200,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = cat.nom_c;
                    });
                  },
                );
              }).toList(),
            ),

            // --- Image Viewer amélioré ---
            if (imgPick) ...[
              const SizedBox(height: 15),
              GridView.builder(
                itemCount: _images.length + 1,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  // --- Bouton "ajouter une image" ---
                  if (index == _images.length) {
                    return GestureDetector(
                      onTap: _pickImage,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(2, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 42,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  }
                  // --- Affichage des images ---
                  final image = _images[index];
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ImagePreviewScreen(
                                images: _images
                                    .map((x) => File(x.path))
                                    .toList(),
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: _images[index].path, // pour animation fluide
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(image.path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                      ),
                      // --- Bouton supprimer ---
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: const Offset(1, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(5),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
            // musique

            // categorie == tache ou travail
            const SizedBox(height: 20),
            if (tache)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 🟩 Champ d'ajout de tâche
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            Colors.grey.shade100, // plus doux que grey.shade50
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.shade300, // moins contrasté
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _champTachecontroller,
                              onSubmitted: ((_) {
                                _appliquerChangementTache();
                              }),
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                hintText: "Ajouter une tâche...",
                                border: InputBorder
                                    .none, // pas de border par défaut
                                enabledBorder: InputBorder
                                    .none, // pas de border quand désactivé
                                focusedBorder: InputBorder
                                    .none, // pas de border quand focus
                                errorBorder:
                                    InputBorder.none, // pas de border d'erreur
                                disabledBorder:
                                    InputBorder.none, // pas de border désactivé
                                fillColor: const Color.fromARGB(
                                  255,
                                  248,
                                  248,
                                  248,
                                ), // fond clair
                                filled: true,
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 18,
                                ),
                                isDense: true,
                              ),
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 🟨 Liste des tâches existantes
                    Expanded(
                      child: _taches.isEmpty
                          ? Center(
                              child: Text(
                                "Aucune tâche pour le moment",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _taches.length,
                              itemBuilder: (context, index) {
                                final task = _taches[index];
                                return _buildTaskItem(task);
                              },
                            ),
                    ),
                  ],
                ),
              ),

            if (audio)
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icône avec animation de fréquences
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _isRecording
                                ? Colors.red.shade50
                                : _isPlaying
                                ? Colors.orange.shade50
                                : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Animation des fréquences sonores (lecture)
                              if (_isPlaying)
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: CustomPaint(
                                    painter: _SoundWavesPainter(
                                      animation: _animationController,
                                      color: Colors.orange.shade300,
                                    ),
                                  ),
                                ),

                              // Animation de pulsation (enregistrement)
                              if (_isRecording)
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: CustomPaint(
                                    painter: _RecordingPulsePainter(
                                      animation: _animationController,
                                      color: Colors.red.shade300,
                                    ),
                                  ),
                                ),

                              // Icône principale
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  _recordedPath == null || _isRecording
                                      ? Icons.mic_rounded
                                      : Icons.audiotrack_rounded,
                                  key: ValueKey(
                                    _recordedPath == null || _isRecording,
                                  ),
                                  size: 80,
                                  color: _isRecording
                                      ? Colors.red.shade400
                                      : _recordedPath != null
                                      ? _isPlaying
                                            ? Colors.orange.shade600
                                            : Colors.grey.shade600
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Les 3 boutons sur la même ligne
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Bouton Enregistrer / Arrêter
                            _buildActionButton(
                              isEnabled: _recordedPath == null || _isRecording,
                              onTap: _isRecording
                                  ? stopRecording
                                  : startRecording,
                              icon: _isRecording
                                  ? Icons.stop_rounded
                                  : Icons.mic_rounded,
                              color: _isRecording
                                  ? Colors.red.shade400
                                  : Colors.blue.shade500,
                              shadowColor: _isRecording
                                  ? Colors.red.shade200
                                  : Colors.blue.shade200,
                            ),
                            const SizedBox(width: 12),

                            // Bouton Lecture / Pause
                            _buildActionButton(
                              isEnabled: _recordedPath != null && !_isRecording,
                              onTap: playRecording,
                              icon: _isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: _isPlaying
                                  ? Colors.orange.shade400
                                  : Colors.green.shade400,
                              shadowColor: _isPlaying
                                  ? Colors.orange.shade200
                                  : Colors.green.shade200,
                            ),
                            const SizedBox(width: 12),

                            // Bouton Supprimer
                            _buildActionButton(
                              isEnabled: _recordedPath != null && !_isRecording,
                              onTap: deleteRecording,
                              icon: Icons.delete_outline_rounded,
                              color: Colors.grey.shade200,
                              shadowColor: Colors.red.shade200,
                              borderColor: Colors.red.shade300,
                              iconColor: Colors.red.shade600,
                              isOutlined: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            //si non tache et non audio
            if (!tache && !audio) ...[
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  // scroll de la page si nécessaire
                  child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null, // pas de limite
                    expands: false, // ne prend que l’espace nécessaire
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.5,
                      color: Color(0xFF616161),
                    ),
                    cursorColor: color,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText:
                          'Écris ici ton idée, ton note de travail ou tes tâches...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      alignLabelWithHint: true,
                      filled: false,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),

      bottomNavigationBar: Container(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 2,
              offset: const Offset(0, -2),
            ),
          ],
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _navItem(Icons.list, "liste"),
            _navItem(Icons.camera_enhance, "image"),
            _navItem(Icons.mic, "audio"),
            _navItem(verouiller ? Icons.lock : Icons.lock_open, "personnel"),
          ],
        ),
      ),
    );
  }

  /// Widget pour chaque tâche
  Widget _buildTaskItem(TacheItem task) {
    return InkWell(
      onTap: () => setState(() => task.fait = !task.fait),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Icon(
              task.fait
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              color: task.fait ? Colors.green.shade600 : Colors.grey.shade500,
              size: 22,
            ),
            const SizedBox(width: 10),
            // 📝 Texte de la tâche
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(
                  8,
                ), // facultatif, si tu veux un effet de bord arrondi
                onTap: () {
                  _tacheEnEdition = task; // task sélectionnée
                  _champTachecontroller.text = task.contenu; // préremplir
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ), // facultatif pour le hit area
                  child: Text(
                    task.contenu,
                    style: TextStyle(
                      fontSize: 14,
                      color: task.fait
                          ? Colors.grey.shade600
                          : Colors.grey.shade900,
                      fontWeight: task.fait ? FontWeight.w400 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            // 🗑️ Bouton de suppression
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () async {
                suppLocal(task);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Méthode unique pour construire les boutons
Widget _buildActionButton({
  required bool isEnabled,
  required VoidCallback onTap,
  required IconData icon,
  required Color color,
  required Color shadowColor,
  Color? borderColor,
  Color? iconColor,
  bool isOutlined = false,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isEnabled ? color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: isOutlined && borderColor != null
              ? Border.all(
                  color: isEnabled ? borderColor : Colors.grey.shade300,
                  width: 2,
                )
              : null,
          boxShadow: isEnabled && !isOutlined
              ? [
                  BoxShadow(
                    color: shadowColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isEnabled ? (iconColor ?? Colors.white) : Colors.grey.shade400,
          size: 28,
        ),
      ),
    ),
  );
}

// CustomPainter pour les ondes sonores (lecture)
class _SoundWavesPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _SoundWavesPainter({required this.animation, required this.color})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(0.6);

    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2;

    for (int i = 0; i < 5; i++) {
      final angle = (i * 72) * (3.14159 / 180);
      final phase = (animation.value + (i * 0.2)) % 1.0;
      final height = 8 + (12 * sin(phase * 3.14159 * 2));
      final x = center.dx + cos(angle) * (baseRadius - 5);
      final y = center.dy + sin(angle) * (baseRadius - 5);

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y), width: 4, height: height),
        const Radius.circular(2),
      );

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle + 3.14159 / 2);
      canvas.translate(-x, -y);
      canvas.drawRRect(rect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SoundWavesPainter oldDelegate) => true;
}

// CustomPainter pour l'animation de pulsation (enregistrement)
class _RecordingPulsePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _RecordingPulsePainter({required this.animation, required this.color})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2;

    // Dessiner 3 cercles concentriques qui pulsent
    for (int i = 0; i < 3; i++) {
      final phase = (animation.value + (i * 0.33)) % 1.0;
      final radius = baseRadius * (0.3 + (phase * 0.7));
      final opacity = 0.6 * (1 - phase);

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = color.withOpacity(opacity);

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_RecordingPulsePainter oldDelegate) => true;
}
