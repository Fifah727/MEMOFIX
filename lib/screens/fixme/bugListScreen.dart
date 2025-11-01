import 'package:flutter/material.dart';
import 'package:memofix/models/fixme/FixMeItems.dart';
import 'package:memofix/services/query/fixme/bug_service.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class BugListScreen extends StatefulWidget {
  const BugListScreen({super.key});

  @override
  State<BugListScreen> createState() => _BugListScreenState();
}

class _BugListScreenState extends State<BugListScreen> {
  final BugService _bugService = BugService();
  late Future<List<BugItem>> _bugsFuture;

  @override
  void initState() {
    super.initState();
    _bugsFuture = _bugService.getBugs();
  }

  Color _getStatutColor(String statut) {
    switch (statut) {
      case 'corrigé':
        return Colors.green;
      case 'abandonné':
        return Colors.red;
      case 'en_cours':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: const Color(0xFFFAFAFA),
        title: const Text(
          'Tous les bugs',
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
              // showSearch(
              //   context: context,
              //   delegate: MemoSearchDelegate(_memos),
              // ).then((result) {
              //   if (result != null) {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (_) => AddMemoPlus(memo: result),
              //       ),
              //     );
              //   }
              // });
            },
          ),
        ],
      ),

      body: FutureBuilder<List<BugItem>>(
        future: _bugsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun bug trouvé"));
          }

          final bugs = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: bugs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final bug = bugs[index];
              return _buildBugCard(bug);
              // return Card(
              //   elevation: 2,
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   child: ListTile(
              //     onTap: () {
              //       // TODO: Navigator vers BugDetailScreen
              //     },
              //     title: Text(
              //       bug.description,
              //       maxLines: 2,
              //       overflow: TextOverflow.ellipsis,
              //       style: const TextStyle(fontWeight: FontWeight.bold),
              //     ),
              //     subtitle: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         const SizedBox(height: 4),
              //         Row(
              //           children: [
              //             Text(
              //               "Statut: ${bug.statut}",
              //               style: TextStyle(
              //                 color: _getStatutColor(bug.statut),
              //                 fontWeight: FontWeight.w500,
              //               ),
              //             ),
              //             const SizedBox(width: 16),
              //             Text(
              //               "Avancement: ${bug.avancement}%",
              //               style: const TextStyle(fontWeight: FontWeight.w500),
              //             ),
              //           ],
              //         ),
              //         const SizedBox(height: 6),
              //         // Barre de progression
              //         ClipRRect(
              //           borderRadius: BorderRadius.circular(6),
              //           child: LinearProgressIndicator(
              //             value: bug.avancement / 100,
              //             minHeight: 6,
              //             backgroundColor: Colors.grey[300],
              //             color: theme.primaryColor,
              //           ),
              //         ),
              //       ],
              //     ),
              //     trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              //   ),
              // );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigator vers BugEditScreen pour ajouter un bug
        },
        tooltip: 'Ajouter un bug',
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  //
  Color _getCategoryColor(String category) {
    final colors = {
      'UI': const Color.fromARGB(255, 206, 219, 255), // bleu nuit foncé
      'Backend': const Color.fromARGB(255, 215, 247, 152), // vert matcha
      'Performance': const Color.fromARGB(255, 229, 192, 255), // violet profond
    };

    return colors[category.toLowerCase()] ??
        Color.fromRGBO(
          (category.hashCode & 0xFF0000) >> 16,
          (category.hashCode & 0x00FF00) >> 8,
          (category.hashCode & 0x0000FF),
          1.0,
        );
  }

  Widget _buildBugCard(BugItem bug) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getCategoryColor(bug.categorie).withOpacity(0.25),
            _getCategoryColor(bug.categorie).withOpacity(0.35),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9AE683).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          bug.categorie,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bug.description,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bug.description,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progression',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          '${bug.avancement}%',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: [
                          Container(
                            height: 6,
                            color: Colors.white.withOpacity(0.25),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                            width: (bug.avancement / 100) * 200,
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.9),
                                  Colors.white.withOpacity(0.6),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatutColor(bug.statut).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        bug.statut,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.trending_up_rounded,
                          size: 17,
                          color: Colors.grey.shade700,
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
    );
  }

  // Widget _buildBugCard(BugItem bug) {
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 18),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [
  //           const Color.fromARGB(255, 148, 245, 161).withOpacity(0.25),
  //           const Color(0xFF9AE683).withOpacity(0.35),
  //         ],
  //       ),
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(
  //           color: const Color(0xFF9AE683).withOpacity(0.15),
  //           blurRadius: 20,
  //           offset: const Offset(0, 10),
  //         ),
  //       ],
  //       border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
  //     ),
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(20),
  //       child: BackdropFilter(
  //         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
  //         child: Padding(
  //           padding: const EdgeInsets.all(18),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               // Header
  //               Row(
  //                 children: [
  //                   Container(
  //                     width: 48,
  //                     height: 48,
  //                     decoration: BoxDecoration(
  //                       color: Colors.white.withOpacity(0.25),
  //                       borderRadius: BorderRadius.circular(14),
  //                     ),
  //                     child: Center(
  //                       child: Text(
  //                         bug.categorie,
  //                         style: const TextStyle(fontSize: 24),
  //                       ),
  //                     ),
  //                   ),
  //                   const SizedBox(width: 14),
  //                   Expanded(
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text(
  //                           bug.description,
  //                           style: TextStyle(
  //                             fontSize: 17,
  //                             fontWeight: FontWeight.w600,
  //                             color: Colors.grey.shade900,
  //                           ),
  //                         ),
  //                         const SizedBox(height: 4),
  //                         Text(
  //                           bug.description,
  //                           style: TextStyle(
  //                             fontSize: 13.5,
  //                             color: Colors.grey.shade700,
  //                             height: 1.4,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),

  //               const SizedBox(height: 18),

  //               // Progress bar
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         'Progression',
  //                         style: TextStyle(
  //                           fontSize: 13.5,
  //                           fontWeight: FontWeight.w500,
  //                           color: Colors.grey.shade700,
  //                         ),
  //                       ),
  //                       Text(
  //                         '${bug.avancement}%',
  //                         style: TextStyle(
  //                           fontSize: 13.5,
  //                           fontWeight: FontWeight.w600,
  //                           color: Colors.grey.shade800,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 8),
  //                   ClipRRect(
  //                     borderRadius: BorderRadius.circular(4),
  //                     child: Stack(
  //                       children: [
  //                         Container(
  //                           height: 6,
  //                           color: Colors.white.withOpacity(0.25),
  //                         ),
  //                         AnimatedContainer(
  //                           duration: const Duration(milliseconds: 400),
  //                           curve: Curves.easeOut,
  //                           width: (bug.avancement / 100) * 200,
  //                           height: 6,
  //                           decoration: BoxDecoration(
  //                             gradient: LinearGradient(
  //                               colors: [
  //                                 Colors.white.withOpacity(0.9),
  //                                 Colors.white.withOpacity(0.6),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),

  //               const SizedBox(height: 18),

  //               // Footer
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Container(
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 12,
  //                       vertical: 6,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       color: Colors.white.withOpacity(0.2),
  //                       borderRadius: BorderRadius.circular(10),
  //                     ),
  //                     child: Text(
  //                       bug.statut,
  //                       style: TextStyle(
  //                         fontSize: 12.5,
  //                         fontWeight: FontWeight.w500,
  //                         color: Colors.grey.shade800,
  //                       ),
  //                     ),
  //                   ),
  //                   InkWell(
  //                     onTap: () {},
  //                     borderRadius: BorderRadius.circular(20),
  //                     child: Container(
  //                       width: 34,
  //                       height: 34,
  //                       decoration: BoxDecoration(
  //                         color: Colors.white.withOpacity(0.25),
  //                         borderRadius: BorderRadius.circular(20),
  //                       ),
  //                       child: Icon(
  //                         Icons.trending_up_rounded,
  //                         size: 17,
  //                         color: Colors.grey.shade700,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
