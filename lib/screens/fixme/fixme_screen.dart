import 'package:flutter/material.dart';

class FixMeScreen extends StatefulWidget {
  const FixMeScreen({super.key});

  @override
  State<FixMeScreen> createState() => _FixMeScreenState();
}

class _FixMeScreenState extends State<FixMeScreen> {
  final List<BugItem> _bugs = [
    BugItem(title: 'Réparer l\'écran de connexion'),
    BugItem(title: 'Corriger le bug de notifications'),
    BugItem(title: 'Améliorer la vitesse de chargement'),
  ];

  final TextEditingController _controller = TextEditingController();
  BugItem? _recentlyDeletedBug;
  int? _recentlyDeletedIndex;

  void _addBug(String title) {
    if (title.trim().isEmpty) return;
    setState(() {
      _bugs.add(BugItem(title: title.trim()));
    });
    _controller.clear();
    Navigator.of(context).pop();
  }

  void _showAddBugDialog() {
    bool isButtonEnabled = false;
    _controller.clear();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Ajouter un bug'),
          content: TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Décrire le bug',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setStateDialog(() {
                isButtonEnabled = value.trim().isNotEmpty;
              });
            },
            onSubmitted: isButtonEnabled ? _addBug : null,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: isButtonEnabled
                  ? () => _addBug(_controller.text)
                  : null,
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteBug(int index) {
    setState(() {
      _recentlyDeletedBug = _bugs[index];
      _recentlyDeletedIndex = index;
      _bugs.removeAt(index);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Bug supprimé'),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () {
            if (_recentlyDeletedBug != null && _recentlyDeletedIndex != null) {
              setState(() {
                _bugs.insert(_recentlyDeletedIndex!, _recentlyDeletedBug!);
              });
            }
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bug_report_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun bug pour le moment.\nClique sur + pour en ajouter.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FixMe'),
        backgroundColor: Colors.deepPurple,
        elevation: 2,
      ),
      body: _bugs.isEmpty
          ? _buildEmptyState(context)
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _bugs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final bug = _bugs[index];
                return Dismissible(
                  key: ValueKey(bug),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  onDismissed: (_) => _deleteBug(index),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CheckboxListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      title: Text(
                        bug.title,
                        style: TextStyle(
                          fontSize: 16,
                          decoration: bug.isDone
                              ? TextDecoration.lineThrough
                              : null,
                          color: bug.isDone ? Colors.grey : null,
                        ),
                      ),
                      value: bug.isDone,
                      activeColor: Colors.deepPurple,
                      onChanged: (value) {
                        setState(() {
                          bug.isDone = value ?? false;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBugDialog,
        backgroundColor: Colors.deepPurple,
        tooltip: 'Ajouter un bug',
        child: const Icon(Icons.add, size: 30),
        elevation: 6,
      ),
    );
  }
}

class BugItem {
  final String title;
  bool isDone;

  BugItem({required this.title, this.isDone = false});
}
