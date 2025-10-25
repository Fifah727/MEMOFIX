import 'package:flutter/material.dart';
import '../../widgets/addMemoPlus.dart';
import 'package:memofix/models/MemoItem.dart';
import 'package:memofix/services/query/memo_service.dart';
import 'package:memofix/screens/home_screen.dart';
import 'modif_memo.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MemoScreen extends StatefulWidget {
  const MemoScreen({super.key});

  @override
  State<MemoScreen> createState() => _MemoScreenState();
}

class _MemoScreenState extends State<MemoScreen> {
  final MemoService memoService = MemoService();

  List<MemoItem> _memos = [];

  final memoVide = MemoItem(
    id: 0,
    titre: "",
    text: "",
    category: "idée",
    createdAt: DateTime.now(),
  );

  Future<void> loadMemos() async {
    try {
      final memos = await memoService.getMemos();
      setState(() {
        _memos = memos;
      });
    } catch (e) {
      debugPrint("Erreur lors du chargement des memos : $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadMemos();
  }

  final TextEditingController _searchController = TextEditingController();
  final String _searchQuery = '';
  String _selectedCategory = 'Toutes';

  final List<String> _categories = [
    'Toutes',
    'Travail',
    'Personnel',
    'Idée',
    'Tâche',
    'Musique',
    'Voyage',
  ];

  void _mettreImportant(MemoItem memo) {
    final updatedMemo = MemoItem(
      id: memo.id,
      titre: memo.titre,
      text: memo.text,
      category: memo.category,
      createdAt: memo.createdAt,
      isImportant: memo.isImportant,
    );
    memoService.important(updatedMemo);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _removeMemo(MemoItem memo) async {
    // supp memos
    try {
      await memoService.supprimerMemo(memo.id);
      print("Memos deleted avec succes");
    } catch (e) {
      debugPrint("Erreur lors de la suppression du memo : $e");
    }
    loadMemos();
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

  // Méthode helper pour les couleurs de catégorie
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

    // Pad à gauche pour gérer les mois à 1 chiffre (ex: '1' -> '01')
    return months[month] ?? '$month';
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inDays == 0) return 'Aujourd’hui';
    if (diff.inDays == 1) return 'Hier';
    return '${dt.day} ${_getMonth(dt.month)}';
  }

  Widget _buildItem(MemoItem memo, int index) {
    return Dismissible(
      key: ValueKey(memo),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeMemo(memo),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'Supprimer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Material(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddMemoPlus(memo: memo)),
              );
            },
            splashColor: const Color.fromARGB(
              255,
              252,
              252,
              252,
            ).withOpacity(0.2),
            highlightColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_getCategoryImage(memo.category)),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- DATE ---
                    Text(
                      _formatDate(memo.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color.fromARGB(255, 163, 163, 163),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // --- TITRE ---
                    Text(
                      memo.titre,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // --- TEXTE DU MEMO ---
                    if (memo.text != null && memo.text!.isNotEmpty)
                      Text(
                        memo.text!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.3,
                        ),
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 10),
                    // --- ETOILE IMPORTANCE en bas à droite ---
                    Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            memo.isImportant
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            key: ValueKey(memo.isImportant),
                            size: 24,
                            color: memo.isImportant
                                ? Colors.amber.shade600
                                : Colors.grey.shade500,
                          ),
                        ),
                        onPressed: () {
                          setState(() => memo.isImportant = !memo.isImportant);
                          _mettreImportant(memo);
                        },
                        tooltip: memo.isImportant
                            ? 'Retirer l\'importance'
                            : 'Marquer comme important',
                        splashRadius: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Fonction qui retourne le chemin de l'image selon la catégorie
  String _getCategoryImage(String? category) {
    switch (category?.toLowerCase()) {
      case 'travail':
        return 'assets/work.jpeg';
      case 'musique':
        return 'assets/music.jpg';
      case 'tâche':
        return 'assets/tache.webp';
      case 'voyage':
        return 'assets/voyage.webp';
      case 'personnel':
        return 'assets/work.jpeg';
      case 'idée':
        return 'assets/idee.jpg';
      default:
        return 'assets/work.jpeg';
    }
  }

  // État vide avec design attractif
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône animée
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.note_add_outlined,
                      size: 60,
                      color: Colors.grey.shade400,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Texte principal
            Text(
              'Aucun mémo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Texte secondaire
            Text(
              'Créez votre premier mémo',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemosList() {
    final filteredMemos = _filteredMemos;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MasonryGridView.count(
        crossAxisCount: 2, // 2 colonnes
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: filteredMemos.length,
        itemBuilder: (context, index) {
          final memo = filteredMemos[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 100)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(30 * (1 - value), 0),
                child: Opacity(
                  opacity: value,
                  child: Hero(
                    tag: 'memo_${memo.hashCode}',
                    child: _buildItem(memo, index),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredMemos = _filteredMemos;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: const Color(0xFFFAFAFA),
        title: const Text(
          'Toutes les mémos',
          style: TextStyle(fontSize: 20, color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(LineIcons.arrowLeft, color: Colors.black87),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Rechercher',
            icon: const Icon(LineIcons.search, color: Colors.black87),
            onPressed: () {
              showSearch(
                context: context,
                delegate: MemoSearchDelegate(_memos),
              ).then((result) {
                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        'Mémo sélectionné : ${result.text}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }
              });
            },
          ),
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // coins plus doux
            ),
            color: Colors.grey.shade100, // fond discret
            onSelected: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            itemBuilder: (context) => _categories
                .map(
                  (cat) => PopupMenuItem(
                    value: cat,
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800, // texte moins contrasté
                      ),
                    ),
                  ),
                )
                .toList(),
            icon: Icon(
              LineIcons.filter,
              color: Colors.grey.shade700, // icône plus discrète
              size: 22,
            ),
            tooltip: 'Filtrer',
            elevation: 2, // ombre très légère
          ),
        ],
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 2, // deux tabs
          child: Column(
            children: [
              // TabBar
              TabBar(
                labelColor: const Color.fromARGB(255, 65, 65, 65),
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Mémos'),
                  Tab(text: 'Catégories'),
                ],
              ),
              // TabBarView
              Expanded(
                child: TabBarView(
                  children: [
                    // Première tab: Memos
                    filteredMemos.isEmpty
                        ? _buildEmptyState()
                        : _buildMemosList(),

                    // Deuxième tab: Categories
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.count(
                        crossAxisCount: 2, // 2 colonnes
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        children: [
                          // _buildCategoryCard('Travail'),
                          // _buildCategoryCard('Personnel'),
                          // _buildCategoryCard('Idée'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddMemoPlus(memo: memoVide)),
          );
        },
        tooltip: 'Ajouter un mémo',
        backgroundColor: theme.primaryColor, // fond discret
        foregroundColor: const Color.fromARGB(255, 50, 66, 16),
        elevation: 2, // ombre légère
        highlightElevation: 2,
        child: const Icon(Icons.add, size: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50), // coins plus arrondis
        ),
      ),
    );
  }
}

class MemoSearchDelegate extends SearchDelegate<MemoItem?> {
  final List<MemoItem> memos;

  MemoSearchDelegate(this.memos);

  @override
  String get searchFieldLabel => 'Rechercher un mémo...';

  @override
  TextStyle? get searchFieldStyle =>
      const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          tooltip: 'Effacer',
          icon: const Icon(Icons.clear, color: Colors.grey),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Retour',
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = memos
        .where((memo) => memo.text.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Aucun résultat trouvé pour "$query"',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final memo = results[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: const Icon(Icons.note, color: Colors.blueAccent),
            title: _highlightText(memo.text, query, context),
            subtitle: Text(
              memo.category,
              style: TextStyle(color: Colors.grey[600]),
            ),
            onTap: () => close(context, memo),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = memos
        .where((memo) => memo.text.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (query.isEmpty) {
      return Center(
        child: Text(
          'Commencez à taper pour rechercher un mémo',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final memo = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.history, color: Colors.grey),
          title: _highlightText(memo.text, query, context),
          subtitle: Text(memo.category),
          onTap: () {
            query = memo.text;
            showResults(context);
          },
        );
      },
    );
  }

  /// Met en évidence la partie de [text] qui correspond à [query].
  Widget _highlightText(String text, String query, BuildContext context) {
    if (query.isEmpty) return Text(text);

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    final startIndex = lowerText.indexOf(lowerQuery);
    if (startIndex == -1) return Text(text);

    final endIndex = startIndex + query.length;

    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyLarge,
        children: [
          TextSpan(text: text.substring(0, startIndex)),
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          TextSpan(text: text.substring(endIndex)),
        ],
      ),
    );
  }
}
