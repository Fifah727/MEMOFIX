import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Classe exemple pour démontrer l'utilisation de Lottie
/// Usage simple : LottieExample()
class LottieExample extends StatefulWidget {
  const LottieExample({Key? key}) : super(key: key);

  @override
  State<LottieExample> createState() => _LottieExampleState();
}

class _LottieExampleState extends State<LottieExample>
    with TickerProviderStateMixin {
  String? selectedCategory;
  late AnimationController _celebrationController;
  bool showCelebration = false;

  // Liste des catégories avec animations
  final List<CategoryAnimation> categories = [
    CategoryAnimation(
      id: 'work',
      name: 'Travail',
      animationPath: 'assets/animations/work.json',
      color: Colors.blue,
      icon: Icons.work,
    ),
    // CategoryAnimation(
    //   id: 'personal',
    //   name: 'Personnel',
    //   animationPath: 'assets/animations/personal.json',
    //   color: Colors.green,
    //   icon: Icons.home,
    // ),
    // CategoryAnimation(
    //   id: 'sport',
    //   name: 'Sport',
    //   animationPath: 'assets/animations/sport.json',
    //   color: Colors.orange,
    //   icon: Icons.sports_soccer,
    // ),
    // CategoryAnimation(
    //   id: 'shopping',
    //   name: 'Shopping',
    //   animationPath: 'assets/animations/shopping.json',
    //   color: Colors.purple,
    //   icon: Icons.shopping_bag,
    // ),
    // CategoryAnimation(
    //   id: 'food',
    //   name: 'Nourriture',
    //   animationPath: 'assets/animations/food.json',
    //   color: Colors.red,
    //   icon: Icons.restaurant,
    // ),
    // CategoryAnimation(
    //   id: 'travel',
    //   name: 'Voyage',
    //   animationPath: 'assets/animations/travel.json',
    //   color: Colors.teal,
    //   icon: Icons.flight,
    // ),
  ];

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  void _selectCategory(CategoryAnimation category) {
    setState(() {
      selectedCategory = category.id;
      showCelebration = true;
    });

    // Jouer l'animation de célébration
    _celebrationController.reset();
    _celebrationController.forward();

    // Cacher la célébration après 2 secondes
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showCelebration = false;
        });
      }
    });

    // Afficher un snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Catégorie "${category.name}" sélectionnée !'),
          ],
        ),
        backgroundColor: category.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Lottie Animation Demo',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Stack(
        children: [
          // Contenu principal
          SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec animation de loading
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Animation de loading simple
                      Container(
                        width: 60,
                        height: 60,
                        child: Lottie.asset(
                          'assets/animations/work.json',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Animations Lottie',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Sélectionnez une catégorie ci-dessous',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Titre de section
                Text(
                  'Choisissez votre catégorie',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),

                SizedBox(height: 16),

                // Grid des catégories
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = selectedCategory == category.id;

                    return GestureDetector(
                      onTap: () => _selectCategory(category),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? category.color
                                : Colors.grey.shade200,
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? category.color.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.1),
                              blurRadius: isSelected ? 12 : 6,
                              spreadRadius: isSelected ? 3 : 1,
                              offset: Offset(0, isSelected ? 6 : 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Zone d'animation Lottie
                            Container(
                              width: 80,
                              height: 80,
                              child: _buildLottieAnimation(
                                category,
                                isSelected,
                              ),
                            ),

                            SizedBox(height: 12),

                            // Nom de la catégorie
                            Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isSelected
                                    ? category.color
                                    : Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: 8),

                            // Indicateur de sélection
                            AnimatedOpacity(
                              opacity: isSelected ? 1.0 : 0.0,
                              duration: Duration(milliseconds: 300),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: category.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: category.color,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Sélectionné',
                                      style: TextStyle(
                                        color: category.color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 24),

                // Bouton d'action si une catégorie est sélectionnée
                if (selectedCategory != null)
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final selected = categories.firstWhere(
                          (cat) => cat.id == selectedCategory,
                        );
                        _showSuccessDialog(selected);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: categories
                            .firstWhere((cat) => cat.id == selectedCategory)
                            .color,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.rocket_launch, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Créer la catégorie',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Animation de célébration en overlay
          if (showCelebration)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    child: Lottie.asset(
                      'assets/animations/work.json',
                      controller: _celebrationController,
                      fit: BoxFit.contain,
                      repeat: false,
                      onLoaded: (composition) {
                        _celebrationController.duration = composition.duration;
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Construit l'animation Lottie avec fallback sur icône
  Widget _buildLottieAnimation(CategoryAnimation category, bool isSelected) {
    return Lottie.asset(
      category.animationPath,
      fit: BoxFit.contain,
      repeat: isSelected,
      // Si l'animation ne se charge pas, afficher une icône de fallback
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: category.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(category.icon, color: category.color, size: 40),
        );
      },
    );
  }

  /// Affiche une dialog de succès avec animation
  void _showSuccessDialog(CategoryAnimation category) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animation de succès
            Container(
              width: 120,
              height: 120,
              child: Lottie.asset(
                'assets/animations/work.json',
                fit: BoxFit.contain,
                repeat: false,
                // Fallback si pas d'animation de succès
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 60,
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 16),

            Text(
              'Parfait !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: category.color,
              ),
            ),

            SizedBox(height: 8),

            Text(
              'La catégorie "${category.name}" a été créée avec succès !',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fermer',
              style: TextStyle(
                color: category.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Classe pour représenter une catégorie avec son animation
class CategoryAnimation {
  final String id;
  final String name;
  final String animationPath;
  final Color color;
  final IconData icon;

  const CategoryAnimation({
    required this.id,
    required this.name,
    required this.animationPath,
    required this.color,
    required this.icon,
  });
}

/// Widget simple pour afficher juste une animation Lottie
class SimpleLottieWidget extends StatelessWidget {
  final String animationPath;
  final double? width;
  final double? height;
  final bool repeat;
  final BoxFit fit;

  const SimpleLottieWidget({
    Key? key,
    required this.animationPath,
    this.width,
    this.height,
    this.repeat = true,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: Lottie.asset(
        animationPath,
        fit: fit,
        repeat: repeat,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width ?? 100,
            height: height ?? 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.animation,
              color: Colors.grey[400],
              size: (width ?? 100) * 0.4,
            ),
          );
        },
      ),
    );
  }
}
