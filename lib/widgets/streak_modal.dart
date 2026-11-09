import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class StreakModal extends StatelessWidget {
  const StreakModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const StreakModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final streak = taskProvider.currentStreak;
    final isDoneToday = taskProvider.isCompletedToday;
    final activeDays = taskProvider.completedDaysThisWeek;

    const daysOfWeek = [
      {'short': 'M', 'day': 1, 'name': 'Mon'},
      {'short': 'T', 'day': 2, 'name': 'Tue'},
      {'short': 'W', 'day': 3, 'name': 'Wed'},
      {'short': 'T', 'day': 4, 'name': 'Thu'},
      {'short': 'F', 'day': 5, 'name': 'Fri'},
      {'short': 'S', 'day': 6, 'name': 'Sat'},
      {'short': 'S', 'day': 7, 'name': 'Sun'},
    ];

    final todayWeekday = DateTime.now().weekday;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE0D8D0),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),

          // Duolingo Fiery Flame Character / Icon
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer fiery glow
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFF9100).withValues(alpha: 0.35),
                      const Color(0xFFFF3D00).withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Inner Flame Container
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB300), Color(0xFFFF5722), Color(0xFFDD2C00)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF5722).withValues(alpha: 0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "🔥",
                    style: TextStyle(fontSize: 48),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Big Streak Counter
          Text(
            "$streak",
            style: const TextStyle(
              fontSize: 54,
              fontWeight: FontWeight.w900,
              color: Color(0xFFFF5722),
              letterSpacing: -1,
              height: 1.1,
            ),
          ),
          const Text(
            "DAY STREAK!",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: Color(0xFF3E2723),
            ),
          ),

          const SizedBox(height: 8),

          // Today's Progress Card (Minimum 3 Tasks per Day)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDoneToday ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDoneToday ? const Color(0xFFA5D6A7) : const Color(0xFFFFCC80),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          isDoneToday ? "✅ " : "🎯 ",
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          isDoneToday ? "Daily Streak Goal Met!" : "Today's Streak Goal",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDoneToday ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "${taskProvider.completedTasksTodayCount} / 3 Tasks",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDoneToday ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (taskProvider.completedTasksTodayCount / 3.0).clamp(0.0, 1.0),
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDoneToday ? const Color(0xFF2E7D32) : const Color(0xFFFF9800),
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isDoneToday
                    ? "🔥 3/3 tasks finished today! Your streak is secured."
                    : "Complete ${3 - taskProvider.completedTasksTodayCount} more task(s) today to count this day in your streak!",
                  style: TextStyle(
                    fontSize: 11,
                    color: isDoneToday ? const Color(0xFF2E7D32) : const Color(0xFF8D6E63),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Weekly Progress Days (Duolingo Style Dots)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF8F5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEBE5DF)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: daysOfWeek.map((item) {
                    final dayInt = item['day'] as int;
                    final isCompletedDay = activeDays.contains(dayInt);
                    final isToday = dayInt == todayWeekday;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item['short'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                            color: isToday ? const Color(0xFFFF5722) : const Color(0xFF8D827A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompletedDay
                                ? const Color(0xFFFF5722)
                                : (isToday ? const Color(0xFFFFF3E0) : Colors.white),
                            border: Border.all(
                              color: isCompletedDay
                                  ? const Color(0xFFFF5722)
                                  : (isToday ? const Color(0xFFFF9100) : const Color(0xFFE0D8D0)),
                              width: isToday ? 2 : 1.5,
                            ),
                            boxShadow: isCompletedDay
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFFF5722).withValues(alpha: 0.35),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: isCompletedDay
                                ? const Text(
                                    "🔥",
                                    style: TextStyle(fontSize: 16),
                                  )
                                : (isToday
                                    ? Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFFFF9100),
                                        ),
                                      )
                                    : null),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                const Text(
                  "🔥 Only days with at least 3 completed tasks keep your streak burning",
                  style: TextStyle(fontSize: 10, color: Color(0xFF8D827A), fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Big Duolingo-style Rounded Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5722),
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: const Color(0xFFDD2C00).withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "CONTINUE",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

