import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/note_provider.dart';
import '../widgets/streak_modal.dart';
import 'tabs/tasks_tab.dart';
import 'tabs/goals_brick_wall_tab.dart';
import 'tabs/history_tab.dart';
import 'tabs/notes_pdf_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    TasksTab(),
    GoalsBrickWallTab(),
    HistoryTab(),
    NotesPdfTab(),
  ];

  final List<String> _titles = const [
    "Tasks & To-Do",
    "Brick Wall Goals",
    "Completed & Pending",
    "Life Notes & Book",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final uid = auth.user?.uid ?? 'guest_local_user';
      Provider.of<GoalProvider>(context, listen: false).updateUserId(uid);
      Provider.of<TaskProvider>(context, listen: false).updateUserId(uid);
      Provider.of<NoteProvider>(context, listen: false).updateUserId(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "🧱 ",
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  _titles[_currentIndex],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2420),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                    color: auth.isFirebaseAvailable ? Colors.green : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  auth.isFirebaseAvailable
                      ? "Cloud Synced (Online/Offline Ready)"
                      : "Local Storage Mode (.env Firebase ready)",
                  style: TextStyle(
                    fontSize: 10,
                    color: auth.isFirebaseAvailable ? Colors.green.shade800 : Colors.brown.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Duolingo-style Streak Badge
          Consumer<TaskProvider>(
            builder: (context, taskProvider, _) {
              final streak = taskProvider.currentStreak;
              final isDoneToday = taskProvider.isCompletedToday;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => StreakModal.show(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDoneToday ? const Color(0xFFFFF3E0) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDoneToday ? const Color(0xFFFF9800) : const Color(0xFFDFD9D2),
                        width: isDoneToday ? 1.5 : 1,
                      ),
                      boxShadow: isDoneToday
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFF9800).withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "🔥",
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "$streak",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: isDoneToday ? const Color(0xFFE65100) : const Color(0xFF756A63),
                          ),
                        ),
                        if (!isDoneToday) ...[
                          const SizedBox(width: 3),
                          Text(
                            "(${taskProvider.completedTasksTodayCount}/3)",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB0A49B),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showAuthModal(context, auth),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFDFD9D2)),
                ),
                child: Row(
                  children: [
                    if (auth.user?.photoUrl != null)
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage(auth.user!.photoUrl!),
                      )
                    else
                      const Icon(
                        Icons.account_circle,
                        size: 22,
                        color: Color(0xFFD84315),
                      ),
                    const SizedBox(width: 6),
                    Text(
                      auth.user?.displayName ?? "Guest",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A403A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _tabs[_currentIndex],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFD84315).withOpacity(0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle, color: Color(0xFFD84315)),
            label: "Tasks",
          ),
          NavigationDestination(
            icon: Icon(Icons.view_quilt_outlined),
            selectedIcon: Icon(Icons.view_quilt, color: Color(0xFFD84315)),
            label: "Brick Goals",
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics, color: Color(0xFFD84315)),
            label: "Overview",
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: Color(0xFFD84315)),
            label: "Journal & PDF",
          ),
        ],
      ),
    );
  }

  void _showAuthModal(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Account & Cloud Sync",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                auth.isAuthenticated
                    ? "Signed in as ${auth.user?.email}"
                    : "Currently running in local offline-first mode. All tasks and goals are persisted locally on this device.",
                style: const TextStyle(fontSize: 13, color: Color(0xFF6E635C)),
              ),
              const SizedBox(height: 16),
              if (!auth.isFirebaseAvailable)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFCC80)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: Color(0xFFE65100)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Firebase keys not set in .env yet. Put your credentials in .env to connect your live Firebase project.",
                          style: TextStyle(fontSize: 11, color: Color(0xFFBF360C)),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              if (!auth.isAuthenticated)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final success = await auth.signInWithGoogle();
                      if (context.mounted && !success && auth.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Sign In info: ${auth.errorMessage}")),
                        );
                      }
                    },
                    icon: const Icon(Icons.login, size: 20),
                    label: const Text("Sign In with Google"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4285F4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      auth.signOut();
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text("Sign Out"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
