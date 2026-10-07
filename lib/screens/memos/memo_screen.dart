import 'package:flutter/material.dart';
import '../../widgets/memo/addMemoPlus.dart';
import 'package:memofix/models/MemoItem.dart';
import 'package:memofix/services/query/memo/memo_service.dart';
import 'package:memofix/models/CategorieItem.dart';
import 'package:memofix/services/query/categorie_service.dart';
import 'package:memofix/screens/home_screen.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:ui';
import 'package:memofix/widgets/memo/schemaScreen.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui'; // pour ImageFilter.blur

enum MemoSortOption { titreAsc, titreDesc, dateAsc, dateDesc, importance }

MemoSortOption _selectedSortOption = MemoSortOption.dateDesc;

class MemoScreen extends StatefulWidget {
  const MemoScreen({super.key});
  @override
  State<MemoScreen> createState() => _MemoScreenState();
}

class _MemoScreenState extends State<MemoScreen> {
  final MemoService memoService = MemoService();
  final CategorieService categorieService = CategorieService();
  // Déclare une variable d'état dans ton State
  double _fabScale = 1.0;

  List<MemoItem> _memos = [];

  final memoVide = MemoItem(
    id: 0,
    titre: "",
    text: "",
    category: 1,
    createdAt: DateTime.now(),
    modifiedAt: DateTime.now(),
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

  List<CategorieItem> _categories = [];
  Future<void> loadCategories() async {
    try {
      final cats = await categorieService.getCategories();
      setState(() {
        _categories = cats;
      });
    } catch (e) {
      debugPrint("Erreur lors du chargement des categories : $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadMemos();
    loadCategories();
  }

  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Toutes';

  void _mettreImportant(MemoItem memo) {
    final updatedMemo = MemoItem(
      id: memo.id,
      titre: memo.titre,
      text: memo.text,
      category: memo.category,
      createdAt: memo.createdAt,
      modifiedAt: DateTime.now(),
      isImportant: memo.isImportant,
    );
    memoService.important(updatedMemo);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MemoItem> get _filteredMemos {
    List<MemoItem> filtered = _memos;

    // Filtre par catégorie si nécessaire
    if (_selectedCategory != "Toutes") {
      filtered = filtered
          .where(
            (memo) => _getCategoryById(
              memo.category,
            ).toLowerCase().contains(_selectedCategory.toLowerCase()),
          )
          .toList();
    }

    // Tri selon l'option sélectionnée
    switch (_selectedSortOption) {
      case MemoSortOption.titreAsc:
        filtered.sort(
          (a, b) => a.titre.toLowerCase().compareTo(b.titre.toLowerCase()),
        );
        break;
      case MemoSortOption.titreDesc:
        filtered.sort(
          (a, b) => b.titre.toLowerCase().compareTo(a.titre.toLowerCase()),
        );
        break;
      case MemoSortOption.dateAsc:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case MemoSortOption.dateDesc:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case MemoSortOption.importance:
        filtered.sort((a, b) {
          // Les importants en premier
          if (a.isImportant && !b.isImportant) return -1;
          if (!a.isImportant && b.isImportant) return 1;
          // Si égal, on peut trier par date décroissante
          return b.createdAt.compareTo(a.createdAt);
        });
        break;
    }

    return filtered;
  }

  String _getMonth(int month) {
    final months = {
      1: 'JAN',
      2: 'FÉV',
      3: 'MAR',
      4: 'AVR',
      5: 'MAI',
      6: 'JUI',
      7: 'JUL',
      8: 'AOÛ',
      9: 'SEP',
      10: 'OCT',
      11: 'NOV',
      12: 'DÉC',
    };

    return months[month] ?? '$month';
  }

  int _selectedIndex = 1;

  final List<String> _routes = [
    '/home',
    '/memo',
    '/bugListe',
    '/screen-deverouiller',
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pushNamed(context, _routes[index]);
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    // Format des heures et minutes
    final hourMinute =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    if (diff.inDays == 0) return "Aujourd’hui à $hourMinute";
    if (diff.inDays == 1) return "Hier à $hourMinute";

    return '${dt.day} ${_getMonth(dt.month)} à $hourMinute';
  }

  Widget _buildItem(MemoItem memo, int index) {
    return _AnimatedMemoCard(
      memo: memo,
      onTap: () {
        if (memo.verrouille) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SchemaScreen(
                correctPattern: [0, 1, 2, 5],
                memo: memo,
                deverouiller: false,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddMemoPlus(memo: memo)),
          );
        }
      },
      onStarTap: () {
        setState(() => memo.isImportant = !memo.isImportant);
        _mettreImportant(memo);
      },
      getCategoryColor: _getCategoryColor,
      getCategoryById: _getCategoryById,
      formatDate: _formatDate,
      removeMemo: _removeMemo,
    );
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

  // Fonction qui retourne le chemin de l'image selon la catégorie

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

  String _getCategoryById(int? idCategory) {
    // getAllCategorie
    final cat = _categories.firstWhere(
      (a) => a.id_c == idCategory,
      orElse: () => CategorieItem(id_c: 0, nom_c: ''), // sécurité
    );
    return cat.nom_c;
  }

  String _getCategoryImage(int? idCategory) {
    // getAllCategorie
    final cat = _categories.firstWhere(
      (a) => a.id_c == idCategory,
      orElse: () => CategorieItem(id_c: 0, nom_c: ''), // sécurité
    );
    switch (cat.nom_c.toLowerCase()) {
      case 'travail':
        return 'assets/work.jpeg';
      case 'musique':
        return 'assets/music.jpg';
      case 'tâche':
        return 'assets/tache.webp';
      case 'voyage':
        return 'assets/voyage.webp';
      case 'personnel':
        return 'assets/secret-5.jpg';
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
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🌫️ Icône avec halo doux
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value.clamp(0.0, 1.0), // ✅ empêche dépassement
                  child: Transform.scale(
                    scale: value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100.withOpacity(0.6),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.sticky_note_2_outlined,
                        size: 45,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // 🩶 Titre discret
            // Titre principal
            Text(
              'Aucun mémo trouvé',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            // Sous-texte léger
            Text(
              'Essayez de créer un mémo ou changez de catégorie',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade500,
                height: 1.4,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // ✨ Petit indicateur doux (optionnel)
            Icon(
              Icons.arrow_downward_rounded,
              color: Colors.grey.shade300,
              size: 24,
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
          onPressed: () => Navigator.pushNamed(
            context,
            "/home",
          ), // Plus simple et plus efficace
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
                  if (result.verrouille) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SchemaScreen(
                          correctPattern: [0, 1, 2, 5],
                          memo: result,
                          deverouiller: false,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddMemoPlus(memo: result),
                      ),
                    );
                  }
                }
              });
            },
          ),
          PopupMenuButton<MemoSortOption>(
            tooltip: 'Trier',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            color: const Color.fromARGB(255, 34, 34, 34),
            onSelected: (value) {
              setState(() {
                _selectedSortOption = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: MemoSortOption.titreAsc,
                child: Text("Titre A → Z"),
              ),
              PopupMenuItem(
                value: MemoSortOption.titreDesc,
                child: Text("Titre Z → A"),
              ),
              PopupMenuItem(
                value: MemoSortOption.dateAsc,
                child: Text("Premiers ajoutés"),
              ),
              PopupMenuItem(
                value: MemoSortOption.dateDesc,
                child: Text("Derniers ajoutés"),
              ),
              PopupMenuItem(
                value: MemoSortOption.importance,
                child: Text("Importants en premiers"), // nouveau
              ),
            ],
            icon: Icon(Icons.sort, color: Colors.grey.shade700),
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
                    RefreshIndicator(
                      onRefresh: () async {
                        _selectedCategory = "Toutes";
                        _selectedSortOption = MemoSortOption.dateDesc;
                        await loadMemos();
                      },
                      child: filteredMemos.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.6,
                                  child: _buildEmptyState(),
                                ),
                              ],
                            )
                          : _buildMemosList(),
                    ),
                    // Deuxième tab: Categories
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: GridView.builder(
                        itemCount: _categories.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 1.0,
                            ),
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final categoryName = cat.nom_c;
                          final categoryImage = _getCategoryImage(cat.id_c);
                          final isSelected = _selectedCategory == categoryName;

                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(
                              milliseconds: 300 + (index * 80),
                            ),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = categoryName;
                                    });
                                  },
                                  child: Stack(
                                    children: [
                                      // Image de fond adoucie
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(18),
                                        child: ColorFiltered(
                                          colorFilter: ColorFilter.mode(
                                            Colors.black.withOpacity(0.15),
                                            BlendMode.darken,
                                          ),
                                          child: Transform.rotate(
                                            angle: math.pi, // rotation de 180°
                                            child: Image.asset(
                                              categoryImage,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Léger dégradé pour lisibilité du texte
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(18),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.black.withOpacity(0.05),
                                                Colors.transparent,
                                              ],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Sélection élégante avec halo léger
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? _getCategoryColor(
                                                    categoryName,
                                                  ).withOpacity(1)
                                                : Colors.transparent,
                                            width: isSelected ? 2 : 1,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: _getCategoryColor(
                                                      categoryName,
                                                    ).withOpacity(0.1),
                                                    blurRadius: 5,
                                                    spreadRadius: 1,
                                                  ),
                                                ]
                                              : [],
                                        ),
                                      ),

                                      // Nom de la catégorie centré
                                      Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.01,
                                                ),
                                                blurRadius: 3,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            categoryName,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.raleway(
                                              color: Colors.white,
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              fontSize: isSelected ? 18 : 16,
                                              letterSpacing: 1.1,
                                              textBaseline:
                                                  TextBaseline.alphabetic,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 1),
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
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Dans le Scaffold :
      floatingActionButton: GestureDetector(
        onTapDown: (_) => setState(() => _fabScale = 1.2), // agrandit au clic
        onTapUp: (_) {
          setState(() => _fabScale = 1.0); // revient à la taille normale
        },
        onTapCancel: () =>
            setState(() => _fabScale = 1.0), // annulation du clic
        child: AnimatedScale(
          scale: _fabScale,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddMemoPlus(memo: memoVide)),
              );
            },
            tooltip: 'Ajouter un mémo',
            backgroundColor: theme.primaryColor.withOpacity(0.9),
            foregroundColor: Colors.white,
            elevation: 2,
            highlightElevation: 6,
            child: const Icon(Icons.add, size: 28),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            hoverColor: theme.primaryColor.withOpacity(1),
            splashColor: Colors.white.withOpacity(0.2),
            mini: false,
          ),
        ),
      ),

      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white.withOpacity(0.95),
          indicatorColor: theme.primaryColor.withOpacity(0.15),
          elevation: 10,
          height: 68,
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              );
            }
            return const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: theme.primaryColor, size: 26);
            }
            return const IconThemeData(color: Colors.black54, size: 24);
          }),
        ),
        child: NavigationBar(
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black.withOpacity(0.08),
          animationDuration: const Duration(milliseconds: 400),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_filled),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.sticky_note_2_sharp),
              label: 'Mémos',
            ),
            NavigationDestination(
              icon: Icon(Icons.bug_report_sharp),
              label: 'Bugs',
            ),
            NavigationDestination(
              icon: Icon(Icons.lock),
              label: 'Déverouillage',
            ),
          ],
        ),
      ),
    );
  }
}

class MemoSearchDelegate extends SearchDelegate<MemoItem?> {
  final List<MemoItem> memos;
  final CategorieService categorieService = CategorieService();

  List<CategorieItem> _categories = [];

  MemoSearchDelegate(this.memos) {
    // Charger les catégories dès la création
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await categorieService.getCategories();
      _categories = cats;
    } catch (e) {
      debugPrint("Erreur lors du chargement des catégories : $e");
    }
  }

  String _getCategoryById(int? idCategory) {
    final cat = _categories.firstWhere(
      (a) => a.id_c == idCategory,
      orElse: () => CategorieItem(id_c: 0, nom_c: ''),
    );
    return cat.nom_c;
  }

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
            const Icon(
              Icons.search_off,
              size: 64,
              color: Color.fromARGB(255, 236, 236, 236),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun résultat trouvé pour "$query"',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color.fromARGB(255, 236, 236, 236),
              ),
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
            leading: Icon(
              memo.verrouille ? Icons.lock : Icons.check_circle_outline,
            ),
            title: _highlightText(memo.text, query, context),
            subtitle: Text(
              _getCategoryById(memo.category),
              style: TextStyle(color: const Color(0xFFA8A8A8)),
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
          title: _highlightText(memo.text, query, context),
          subtitle: Text(
            _getCategoryById(memo.category),
            style: TextStyle(color: const Color(0xFFA8A8A8)),
          ),
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

class _AnimatedMemoCard extends StatefulWidget {
  final MemoItem memo;
  final VoidCallback onTap;
  final VoidCallback onStarTap;
  final Color Function(String) getCategoryColor;
  final String Function(int) getCategoryById;
  final String Function(DateTime) formatDate;
  final Future<void> Function(MemoItem) removeMemo;

  const _AnimatedMemoCard({
    required this.memo,
    required this.onTap,
    required this.onStarTap,
    required this.getCategoryColor,
    required this.getCategoryById,
    required this.formatDate,
    required this.removeMemo,
  });

  @override
  State<_AnimatedMemoCard> createState() => _AnimatedMemoCardState();
}

class _AnimatedMemoCardState extends State<_AnimatedMemoCard> {
  bool _isPressed = false;
  final MemoService memoService = MemoService();

  @override
  Widget build(BuildContext context) {
    final memo = widget.memo;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _isPressed
                ? const Color.fromARGB(255, 224, 241, 209)
                // 💡 fond plus clair lors du clic
                : Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isPressed ? 0.07 : 0.03),
                blurRadius: _isPressed ? 8 : 4,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Dismissible(
            key: ValueKey(memo),
            direction: DismissDirection.endToStart,
            onDismissed: (_) async {
              await widget.removeMemo(memo);
            },
            background: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(15),
              ),
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
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- DATE + verrou ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.formatDate(memo.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 150, 150, 150),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (memo.verrouille)
                        const Icon(
                          Icons.lock_outline,
                          size: 15,
                          color: Colors.black,
                        ),
                    ],
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

                  // --- TEXTE ---
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

                  // --- CATÉGORIE + ÉTOILE ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget
                              .getCategoryColor(
                                widget.getCategoryById(memo.category),
                              )
                              .withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.getCategoryById(memo.category),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onStarTap,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
