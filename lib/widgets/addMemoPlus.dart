import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:line_icons/line_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:memofix/models/MemoItem.dart';
import 'package:memofix/services/query/memo_service.dart';
import 'package:memofix/screens/memos/memo_screen.dart';

class AddMemoPlus extends StatefulWidget {
  final MemoItem memo;

  const AddMemoPlus({super.key, required this.memo});

  @override
  State<AddMemoPlus> createState() => _AddMemoPlusState();
}

class _AddMemoPlusState extends State<AddMemoPlus> {
  late TextEditingController _titleController;
  late TextEditingController _textController;
  late String _selectedCategory;
  File? _selectedImage;
  String? _audioPath;
  String? _musicTitle;

  final MemoService memoService = MemoService();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.memo.category;
    //
    _titleController = TextEditingController(text: widget.memo.titre);
    _textController = TextEditingController(text: widget.memo.text);
  }

  void _enregMemo() async {
    // modif
    if (widget.memo.id != 0) {
      final updatedMemo = MemoItem(
        id: widget.memo.id,
        titre: _titleController.text,
        text: _textController.text,
        category: _selectedCategory,
        createdAt: widget.memo.createdAt,
      );
      memoService.modifMemo(updatedMemo);
      Navigator.pushReplacementNamed(context, '/memo');
      return;
    }

    // ajout
    final titreInput = _titleController.text.trim();
    final text = _textController.text.trim();
    if (titreInput.isEmpty && text.isEmpty) {
      return;
    }
    String titre;
    if (titreInput.isEmpty) {
      final premierMot = text.split(RegExp(r'\s+')).first;
      titre = premierMot.length > 30
          ? '${premierMot.substring(0, 20)}...'
          : premierMot;
    } else {
      titre = titreInput;
    }

    final newmemo = MemoItem(
      titre: titre,
      text: text,
      category: _selectedCategory,
      createdAt: DateTime.now(),
    );

    //
    try {
      final id_new_memo = await memoService.ajouterMemo(newmemo);
      if (id_new_memo != null) {
        Navigator.pushReplacementNamed(context, '/memo');
      } else
        print("Erreur lors de creation du memo");
    } catch (e) {
      debugPrint("Erreur lors de la creation du memo : $e");
    }

    //
  }

  final _categories = [
    'travail',
    'personnel',
    'idée',
    'tâche',
    'musique',
    'voyage',
  ];

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  void _execute(BuildContext context, String media) {
    switch (media) {
      case 'liste':
      case 'image':
        _pickImage();
      case 'audio':
      case 'musique':
      case 'personnel':
    }
  }

  Widget _buildExtraFields() {
    switch (_selectedCategory) {
      case 'travail':
      case 'tâche':
        return _navItem(Icons.list, "liste");
      case 'voyage':
        return _navItem(Icons.camera_enhance, "image");
      case 'idée':
        return _navItem(Icons.mic, "audio");
      case 'musique':
        return _navItem(Icons.music_note, "musique");
      case 'personnel':
        return _navItem(Icons.lock, "personnel");
      default:
        return const SizedBox();
    }
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
        title: const Text(
          'Nouveau Mémo',
          style: TextStyle(fontSize: 20, color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(LineIcons.arrowLeft, color: Colors.black87),
          onPressed: () => Navigator.pushNamed(context, '/memo'),
        ),
        actions: [
          IconButton(
            icon: Icon(LineIcons.check, color: theme.primaryColor),
            onPressed: _enregMemo,
          ),
        ],
      ),

      body: Container(
        child: SingleChildScrollView(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Champ titre
                TextField(
                  controller: _titleController,
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
                    focusedBorder:
                        InputBorder.none, // pas de border quand focus
                    hintText: "Titre...",
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 80, 80, 80),
                    ),
                    filled: false,
                    isDense: true, // réduit la hauteur interne
                    contentPadding: EdgeInsets.zero, // supprime padding interne
                  ),
                ),

                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  children: _categories.map((cat) {
                    final selected = _selectedCategory == cat;
                    final catColor = _getCategoryColor(cat);

                    return ChoiceChip(
                      avatar: Icon(
                        getCategoryIcon(cat),
                        color: selected ? Colors.white : Colors.grey.shade700,
                        size: 20,
                      ),
                      label: Text(
                        cat,
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
                          _selectedCategory = cat;
                          _selectedImage = null;
                          _audioPath = null;
                          _musicTitle = null;
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: _textController,
                  maxLines: 6,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.5,
                    color: Color(0xFF616161),
                  ),
                  cursorColor: color,
                  decoration: InputDecoration(
                    border: InputBorder.none, // pas de border
                    enabledBorder:
                        InputBorder.none, // pas de border quand désactivé
                    focusedBorder:
                        InputBorder.none, // pas de border quand focus
                    hintText: 'Écris ici ton idée, ta note ou ta tâche...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    alignLabelWithHint: true,

                    filled: false,
                    isDense: true, // réduit la hauteur interne
                    contentPadding: EdgeInsets.zero, // supprime padding interne
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 248, 248, 248),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [_buildExtraFields()],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String key) {
    final color = _getCategoryColor(_selectedCategory);

    return GestureDetector(
      onTap: () => _execute(context, key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, size: 30, color: color)],
        ),
      ),
    );
  }
}
