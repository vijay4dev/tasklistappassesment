import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklistapp/app/app_theme.dart';
import 'package:tasklistapp/auth/auth_services.dart';
import 'package:tasklistapp/dashboard/task_add_sheet.dart';
import 'package:tasklistapp/widgets/commonwidgets.dart';
import '../dashboard/task_provider.dart';
import '../dashboard/task_tile.dart';

// ─── ThemeProvider ─────────────────────────────────────────────────────────
// Light/Dark toggle ke liye
// Yahan rakha hai kyunki sirf dashboard se toggle hota hai abhi
class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool      get isDark     => _isDark;
  ThemeMode get themeMode  => _isDark ? ThemeMode.dark : ThemeMode.light;
  void toggle() { _isDark = !_isDark; notifyListeners(); }
}

// ─── DashboardScreen ────────────────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  // TickerProviderStateMixin = multiple animations ke liye
  // SingleTicker = ek ke liye, Ticker = multiple ke liye

  late AnimationController _headerAnim;
  late Animation<double>   _headerFade;
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFade = CurvedAnimation(
      parent: _headerAnim, curve: Curves.easeOut,
    );
    _headerAnim.forward();

    // Widget tree ready hone ke baad tasks fetch karo
    // initState mein direct async call nahi kar sakte — context ready nahi hota
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchTasks();
    });
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth         = context.watch<AuthService>();
    final taskProvider = context.watch<TaskProvider>();
    // watch kyun? Tasks list ya filter badlega toh screen rebuild hona chahiye

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          // ─── Header (fade in animation) ─────────────────────
          FadeTransition(
            opacity: _headerFade,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(children: [
                // ─── Top Row ────────────────────────────────────
                Row(children: [
                  // Greeting + Name
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_greeting(),
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text(auth.userDisplayName,
                        style: Theme.of(context).textTheme.headlineLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )),

                  // Search Toggle Button
                  IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _showSearch ? Icons.search_off_rounded : Icons.search_rounded,
                        key: ValueKey(_showSearch), // Key change → animation trigger
                      ),
                    ),
                    onPressed: () {
                      setState(() => _showSearch = !_showSearch);
                      if (!_showSearch) {
                        _searchController.clear();
                        taskProvider.setSearch('');
                      }
                    },
                  ),

                  // Theme Toggle
                  Consumer<ThemeProvider>(
                    // Consumer: sirf ye icon rebuild hoga jab theme badle
                    // Poora screen nahi
                    builder: (_, themeProvider, __) => IconButton(
                      icon: Icon(themeProvider.isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded),
                      onPressed: themeProvider.toggle,
                    ),
                  ),

                  // User Avatar + Popup Menu
                  PopupMenuButton<String>(
                    icon: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        auth.userDisplayName[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white,
                            fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    onSelected: (val) {
                      if (val == 'logout') _confirmLogout(context);
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        enabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(auth.userDisplayName,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(auth.user?.email ?? '',
                              style: const TextStyle(fontSize: 12,
                                  color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(children: [
                          Icon(Icons.logout_rounded, size: 18,
                              color: AppTheme.errorColor),
                          SizedBox(width: 10),
                          Text('Sign Out',
                              style: TextStyle(color: AppTheme.errorColor)),
                        ]),
                      ),
                    ],
                  ),
                ]),

                // ─── Search Bar (animated size) ────────────────
                AnimatedSize(
                  // AnimatedSize: content ke andar bahar hone pe smooth resize
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _showSearch
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: TextFormField(
                            controller: _searchController,
                            onChanged: taskProvider.setSearch,
                            decoration: InputDecoration(
                              hintText: 'Search tasks...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded),
                                      onPressed: () {
                                        _searchController.clear();
                                        taskProvider.setSearch('');
                                      },
                                    )
                                  : null,
                            ),
                            autofocus: true,
                          ),
                        )
                      : const SizedBox.shrink(), // Empty widget jab hidden ho
                ),

                const SizedBox(height: 20),
                // ─── Stats Card ───────────────────────────────
                _StatsCard(taskProvider: taskProvider),
                const SizedBox(height: 20),
                // ─── Filter Chips ─────────────────────────────
                _FilterChips(taskProvider: taskProvider),
                const SizedBox(height: 8),
              ]),
            ),
          ),

          // ─── Task List ────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              // Pull to refresh
              onRefresh: taskProvider.fetchTasks,
              color: AppTheme.primaryColor,
              child: taskProvider.isLoading
                  ? const _LoadingSkeletons()
                  : taskProvider.tasks.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.task_alt_rounded, size: 80),
                            const SizedBox(height: 20),
                            const Text("No tasks found"),
                          ],
                        ),
                      )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                          itemCount: taskProvider.tasks.length,
                          itemBuilder: (_, index) {
                            final task = taskProvider.tasks[index];
                            return _AnimatedTaskItem(
                              key: ValueKey(task.id),
                              index: index,
                              child: TaskTile(
                                task: task,
                                onEdit: () => AddTaskSheet.show(context,
                                    existingTask: task),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddTaskSheet.show(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<TaskProvider>().clear(); // Tasks clear karo
              context.read<AuthService>().signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              minimumSize: const Size(80, 40),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Card ────────────────────────────────────────────────────────────
class _StatsCard extends StatelessWidget {
  final TaskProvider taskProvider;
  const _StatsCard({required this.taskProvider});

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Your Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.85),
                  )),
                const SizedBox(height: 4),
                Text(
                  '${taskProvider.completed}/${taskProvider.total} done',
                  style: const TextStyle(color: Colors.white,
                      fontSize: 28, fontWeight: FontWeight.w700),
                ),
              ]),
              // Circular progress
              SizedBox(width: 64, height: 64,
                child: Stack(alignment: Alignment.center, children: [
                  CircularProgressIndicator(
                    value: taskProvider.completedRate,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    strokeWidth: 3,
                  ),
                  Text('${(taskProvider.completed * 100).toInt()}%',
                    style: const TextStyle(color: Colors.white,
                        fontSize: 8, fontWeight: FontWeight.w700)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Linear progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: taskProvider.completedRate,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            _StatChip(icon: Icons.pending_outlined,
                label: '${taskProvider.pending} pending'),
            const SizedBox(width: 12),
            _StatChip(icon: Icons.check_circle_outline_rounded,
                label: '${(taskProvider.completedRate * 100).toInt()}% done'),
          ]),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white, size: 14),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white,
            fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ─── Filter Chips ──────────────────────────────────────────────────────────
class _FilterChips extends StatelessWidget {
  final TaskProvider taskProvider;
  const _FilterChips({required this.taskProvider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: TaskFilter.values.map((f) {
          final isSelected = taskProvider.filter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: FilterChip(
                selected: isSelected,
                label: Text(_label(f)),
                avatar: Icon(_icon(f), size: 16),
                onSelected: (_) => taskProvider.setFilter(f),
                selectedColor: AppTheme.primaryColor.withOpacity(0.15),
                checkmarkColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                side: BorderSide.none,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(TaskFilter f) {
    switch (f) {
      case TaskFilter.all:       return 'All';
      case TaskFilter.pending:   return 'Pending';
      case TaskFilter.completed: return 'Completed';
    }
  }

  IconData _icon(TaskFilter f) {
    switch (f) {
      case TaskFilter.all:       return Icons.list_rounded;
      case TaskFilter.pending:   return Icons.pending_outlined;
      case TaskFilter.completed: return Icons.check_circle_outline_rounded;
    }
  }
}

// ─── Animated Task Item ────────────────────────────────────────────────────
// List mein naya item add hone pe slide + fade animation
class _AnimatedTaskItem extends StatefulWidget {
  final Widget child;
  final int index; // Index ke hisaab se delay karenge
  const _AnimatedTaskItem({super.key, required this.child, required this.index});

  @override
  State<_AnimatedTaskItem> createState() => _AnimatedTaskItemState();
}

class _AnimatedTaskItemState extends State<_AnimatedTaskItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    // Index badne ke saath duration badhe — staggered animation effect
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + widget.index * 40),
    );
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child));
  }
}

// ─── Loading Skeletons ─────────────────────────────────────────────────────
// Tasks fetch ho rahe hain tab dikhao (shimmer-like pulse animation)
class _LoadingSkeletons extends StatelessWidget {
  const _LoadingSkeletons();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      itemCount: 5,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _PulsingBox(isDark: isDark),
      ),
    );
  }
}

class _PulsingBox extends StatefulWidget {
  final bool isDark;
  const _PulsingBox({required this.isDark});
  @override
  State<_PulsingBox> createState() => _PulsingBoxState();
}

class _PulsingBoxState extends State<_PulsingBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true); // Baar baar repeat, forward + backward
    _anim = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: widget.isDark
                ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
