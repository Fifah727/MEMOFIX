import 'package:flutter/material.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  // Exemple de tâches
  final List<TaskItem> tasks = [
    TaskItem(title: "Corriger bug écran d'accueil"),
    TaskItem(title: "Ajouter fonctionnalité recherche"),
    TaskItem(title: "Optimiser base de données"),
    TaskItem(title: "Refaire le design du bouton"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ma Checklist"),
        backgroundColor: Colors.green.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return _buildTaskItem(task);
                },
              ),
            ),
            const SizedBox(height: 12),
            _buildAddTaskField(),
          ],
        ),
      ),
    );
  }

  /// Widget pour chaque tâche
  Widget _buildTaskItem(TaskItem task) {
    return GestureDetector(
      onTap: () => setState(() => task.isDone = !task.isDone),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: task.isDone
              ? Colors.green.shade100
              : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: task.isDone ? Colors.green.shade600 : Colors.transparent,
                border: Border.all(
                  color: task.isDone
                      ? Colors.green.shade600
                      : Colors.grey.shade400,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: task.isDone
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 15,
                  color: task.isDone
                      ? Colors.grey.shade700
                      : Colors.grey.shade900,
                  decoration: task.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Champ pour ajouter une nouvelle tâche
  Widget _buildAddTaskField() {
    final controller = TextEditingController();
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Ajouter une tâche...",
              filled: true,
              fillColor: Colors.white.withOpacity(0.7),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            if (controller.text.trim().isNotEmpty) {
              setState(() {
                tasks.add(TaskItem(title: controller.text.trim()));
                controller.clear();
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// Classe pour stocker une tâche
class TaskItem {
  final String title;
  bool isDone;
  TaskItem({required this.title, this.isDone = false});
}
