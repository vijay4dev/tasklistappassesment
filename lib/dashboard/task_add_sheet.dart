import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklistapp/app/app_theme.dart';
import '../dashboard/task_model.dart';
import '../dashboard/task_provider.dart';
import '../utils/validators.dart';

class AddTaskSheet extends StatefulWidget {
  final Task? existingTask;

  const AddTaskSheet({super.key, this.existingTask});

  static Future<void> show(BuildContext context,{Task? existingTask}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskSheet(existingTask: existingTask),
    );
  }

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet>
    with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _title;
  late TextEditingController _desc;
  late TextEditingController _category;

  late TaskPriority _priority;

  bool _loading = false;

  late AnimationController _controller;
  late Animation<double> _scale;

  bool get editing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();

    _title = TextEditingController(text: widget.existingTask?.title ?? '');
    _desc = TextEditingController(text: widget.existingTask?.description ?? '');
    _category = TextEditingController(text: widget.existingTask?.category ?? '');

    _priority = widget.existingTask?.priority ?? TaskPriority.medium;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scale = Tween(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _title.dispose();
    _desc.dispose();
    _category.dispose();
    super.dispose();
  }

  Future<void> submit() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final provider = context.read<TaskProvider>();

    bool ok;

    if (editing) {

      final updated = widget.existingTask!.copyWith(
        title: _title.text.trim(),
        description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
        category: _category.text.trim().isEmpty ? null : _category.text.trim(),
        priority: _priority,
      );

      ok = await provider.updateTask(updated);

    } else {

      ok = await provider.addTask(
        title: _title.text.trim(),
        description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
        category: _category.text.trim().isEmpty ? null : _category.text.trim(),
        priority: _priority,
      );
    }

    if (!mounted) return;

    setState(() => _loading = false);

    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    final padding = MediaQuery.of(context).viewInsets;

    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(
        scale: _scale.value,
        child: child,
      ),

      child: Container(
        margin: const EdgeInsets.only(top: 60),

        padding: EdgeInsets.fromLTRB(
          24,
          8,
          24,
          padding.bottom + 24,
        ),

        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
        ),

        child: SingleChildScrollView(
          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _handle(),

                _header(theme),

                const SizedBox(height: 20),

                _titleField(),

                const SizedBox(height: 16),

                _descField(),

                const SizedBox(height: 16),

                _categoryField(),

                const SizedBox(height: 20),

                _prioritySelector(),

                const SizedBox(height: 30),

                _buttons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _handle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _header(ThemeData theme) {
    return Row(
      children: [

        const Icon(Icons.task_alt),

        const SizedBox(width: 10),

        Text(
          editing ? "Edit Task" : "New Task",
          style: theme.textTheme.titleLarge,
        ),
      ],
    );
  }

  Widget _titleField() {
    return TextFormField(
      controller: _title,
      validator: Validators.taskTitle,
      decoration: const InputDecoration(
        labelText: "Task title",
      ),
    );
  }

  Widget _descField() {
    return TextFormField(
      controller: _desc,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: "Description",
      ),
    );
  }

  Widget _categoryField() {
    return TextFormField(
      controller: _category,
      decoration: const InputDecoration(
        labelText: "Category",
      ),
    );
  }

  Widget _prioritySelector() {
    return Row(
      children: TaskPriority.values.map((p) {

        final selected = _priority == p;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _priority = p),

            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),

              decoration: BoxDecoration(
                border: Border.all(
                  color: selected
                      ? AppTheme.primaryColor
                      : Colors.grey.shade300,
                ),

                borderRadius: BorderRadius.circular(10),
              ),

              child: Center(child: Text(p.name)),
            ),
          ),
        );

      }).toList(),
    );
  }

  Widget _buttons() {
    return Row(
      children: [

        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: ElevatedButton(
            onPressed: _loading ? null : submit,

            child: _loading
                ? const CircularProgressIndicator()
                : Text(editing ? "Save" : "Add"),
          ),
        ),
      ],
    );
  }
}