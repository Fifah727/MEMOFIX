import 'package:flutter/material.dart';

class MemoScreen extends StatefulWidget {
  const MemoScreen({super.key});

  @override
  State<MemoScreen> createState() => _MemoScreenState();
}

class _MemoScreenState extends State<MemoScreen> {
  List<MemoItem> _memos = [
    MemoItem(
      text:
          'Préparer la présentation de lundi.\n- Diapos clés\n- Notes à intégrer',
      category: 'Travail',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MemoItem(
      text: 'Appeler Fifaliana pour le projet.',
      category: 'Personnel',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      isImportant: true,
    ),
    MemoItem(
      text: 'Faire les courses :\n- Lait\n- Œufs\n- Pain',
      category: 'Urgent',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Toutes';

  final List<String> _categories = ['Toutes', 'Travail', 'Personnel', 'Urgent'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addMemo(MemoItem memo) {
    setState(() {
      _memos.insert(0, memo);
    });
  }

  void _removeMemo(MemoItem memo) {
    setState(() {
      _memos.remove(memo);
    });
  }

  List<MemoItem> get _filteredMemos {
    return _memos.where((memo) {
      final matchesCategory =
          _selectedCategory == 'Toutes' || memo.category == _selectedCategory;
      final matchesSearch = memo.text.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _showAddMemoDialog() {
    final TextEditingController textController = TextEditingController();
    String category = _categories[1];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un mémo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Écris ton mémo ici',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .skip(1)
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    category = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = textController.text.trim();
              if (text.isEmpty) return;
              _addMemo(
                MemoItem(
                  text: text,
                  category: category,
                  createdAt: DateTime.now(),
                ),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(MemoItem memo, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Dismissible(
        key: ValueKey(memo),
        background: Container(
          color: Colors.redAccent,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) => _removeMemo(memo),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          title: Text(
            memo.text,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: memo.isImportant
                  ? FontWeight.w700
                  : FontWeight.normal,
              fontSize: 16,
              color: memo.isImportant ? Colors.amber[700] : null,
            ),
          ),
          subtitle: Text(
            '${memo.category} • ${_formatDate(memo.createdAt)}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: IconButton(
            icon: Icon(
              memo.isImportant ? Icons.star : Icons.star_border,
              color: memo.isImportant ? Colors.amber : null,
            ),
            onPressed: () {
              setState(() {
                memo.isImportant = !memo.isImportant;
              });
            },
            tooltip: memo.isImportant
                ? 'Retirer importance'
                : 'Marquer comme important',
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inDays == 0) return 'Aujourd’hui';
    if (diff.inDays == 1) return 'Hier';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final filteredMemos = _filteredMemos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Mémos'),
        actions: [
          IconButton(
            tooltip: 'Rechercher',
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: MemoSearchDelegate(_memos),
              ).then((result) {
                if (result != null) {
                  // Par exemple, sélectionner ou afficher le mémo trouvé
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Mémo sélectionné : ${result.text}'),
                    ),
                  );
                }
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            itemBuilder: (context) => _categories
                .map((cat) => PopupMenuItem(value: cat, child: Text(cat)))
                .toList(),
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrer par catégorie',
          ),
        ],
      ),
      body: filteredMemos.isEmpty
          ? Center(
              child: Text(
                'Aucun mémo.\nAppuie sur + pour en ajouter.',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: filteredMemos.length,
              itemBuilder: (context, index) {
                final memo = filteredMemos[index];
                return _buildItem(memo, index);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMemoDialog,
        tooltip: 'Ajouter un mémo',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MemoItem {
  final String text;
  final String category;
  final DateTime createdAt;
  bool isImportant;

  MemoItem({
    required this.text,
    this.category = 'Personnel',
    required this.createdAt,
    this.isImportant = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoItem &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          createdAt == other.createdAt;

  @override
  int get hashCode => text.hashCode ^ createdAt.hashCode;
}

class MemoSearchDelegate extends SearchDelegate<MemoItem?> {
  final List<MemoItem> memos;

  MemoSearchDelegate(this.memos);

  @override
  String get searchFieldLabel => 'Rechercher un mémo';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          tooltip: 'Effacer',
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return BackButton(onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = memos
        .where((memo) => memo.text.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          'Aucun résultat pour "$query".',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final memo = results[index];
        return ListTile(
          title: Text(memo.text),
          subtitle: Text(memo.category),
          onTap: () => close(context, memo),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = memos
        .where((memo) => memo.text.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final memo = suggestions[index];
        return ListTile(
          title: Text(memo.text),
          subtitle: Text(memo.category),
          onTap: () {
            query = memo.text;
            showResults(context);
          },
        );
      },
    );
  }
}
