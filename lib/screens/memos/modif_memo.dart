import 'package:flutter/material.dart';
import 'package:memofix/models/MemoItem.dart';
import 'package:memofix/services/query/memo_service.dart';

class ModifMemo extends StatefulWidget {
  final MemoItem memo;

  const ModifMemo({Key? key, required this.memo}) : super(key: key);

  @override
  State<ModifMemo> createState() => _ModifMemoState();
}

class _ModifMemoState extends State<ModifMemo> {
  final MemoService memoService = MemoService();
  late TextEditingController _titreController;
  late TextEditingController _textController;
  late bool _isImportant;
  int _wordCount = 0;

  @override
  void initState() {
    super.initState();
    _titreController = TextEditingController(text: widget.memo.titre);
    _textController = TextEditingController(text: widget.memo.text);
    _isImportant = widget.memo.isImportant;
    _textController.addListener(_updateLetterCount);
    _updateLetterCount();
  }

  void _updateLetterCount() {
    final text = _textController.text;
    setState(() {
      _wordCount = text.length; // nombre de caractères
    });
  }

  @override
  void dispose() {
    _titreController.dispose();
    _textController.dispose();
    _textController.removeListener(_updateLetterCount);
    super.dispose();
  }

  void _autoSave() {
    final updatedMemo = MemoItem(
      id: widget.memo.id,
      titre: _titreController.text,
      text: _textController.text,
      category: widget.memo.category,
      createdAt: widget.memo.createdAt,
      isImportant: _isImportant,
    );
    memoService.modifMemo(updatedMemo);
  }

  void _saveAndExit() async {
    _autoSave();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _titreController,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          cursorColor: Colors.white, // couleur du curseur
          decoration: const InputDecoration(
            border: InputBorder.none, // pas de border
            enabledBorder: InputBorder.none, // pas de border quand désactivé
            focusedBorder: InputBorder.none, // pas de border quand focus
            hintText: "Titre du mémo...",
            hintStyle: TextStyle(color: Colors.white70),
            isDense: true, // réduit la hauteur interne
            contentPadding: EdgeInsets.zero, // supprime padding interne
          ),
        ),

        actions: [
          IconButton(
            icon: Icon(
              _isImportant ? Icons.star : Icons.star_border,
              color: _isImportant ? Colors.amber : Colors.white,
            ),
            tooltip: _isImportant ? 'Important' : 'Marquer comme important',
            onPressed: () {
              setState(() => _isImportant = !_isImportant);
            },
          ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: "Enregistrer",
            onPressed: _saveAndExit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true, // occupe tout l'espace vertical disponible
                keyboardType: TextInputType.multiline,
                style: const TextStyle(fontSize: 16, height: 1.5),
                cursorColor: Colors.blueGrey, // couleur du curseur
                decoration: const InputDecoration(
                  border: InputBorder.none, // pas de bordure
                  enabledBorder:
                      InputBorder.none, // pas de bordure quand désactivé
                  focusedBorder: InputBorder.none, // pas de bordure quand focus
                  hintText: "Écrire votre mémo ici...",
                  hintStyle: TextStyle(color: Colors.black45),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8.0, // padding à gauche/droite
                    vertical: 8.0, // padding en haut/bas
                  ), // supprime padding interne
                  filled: true, // nécessaire pour fillColor
                  fillColor: Colors.transparent, // transparent
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$_wordCount mots',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
