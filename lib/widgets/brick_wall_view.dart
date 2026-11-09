import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/goal_model.dart';
import '../models/task_model.dart';

class BrickWallView extends StatelessWidget {
  final GoalModel goal;
  final List<TaskModel> linkedTasks;
  final VoidCallback? onAddTask;

  const BrickWallView({
    super.key,
    required this.goal,
    required this.linkedTasks,
    this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final completedTasks = linkedTasks.where((t) => t.isCompleted).toList()
      ..sort((a, b) => (a.completedAt ?? a.createdAt).compareTo(b.completedAt ?? b.createdAt));

    final completedCount = completedTasks.length;
    final totalBricks = goal.targetBricks;
    final progress = totalBricks > 0 ? (completedCount / totalBricks).clamp(0.0, 1.0) : 0.0;
    final percent = (progress * 100).toInt();

    final goalColor = Color(goal.colorValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: const Color(0xFFECE6E0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C2523),
                          ),
                        ),
                        if (goal.description != null && goal.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            goal.description!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF7A706A),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: goalColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$percent%",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: goalColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFFEDE8E3),
                  valueColor: AlwaysStoppedAnimation<Color>(goalColor),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text("🧱 ", style: TextStyle(fontSize: 16)),
                      Text(
                        "$completedCount of $totalBricks bricks laid",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A403A),
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: onAddTask,
                    icon: const Icon(Icons.add_task, size: 16),
                    label: const Text("Add Task"),
                    style: TextButton.styleFrom(
                      foregroundColor: goalColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              const Icon(Icons.dashboard_outlined, size: 18, color: Color(0xFF7A706A)),
              const SizedBox(width: 8),
              const Text(
                "Brick Wall Masonry",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A403A),
                ),
              ),
              const Spacer(),
              const Text(
                "Tap any brick for details",
                style: TextStyle(fontSize: 11, color: Color(0xFF9E948D), fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3ECE6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDFD7CF), width: 1.5),
            ),
            child: _buildStaggeredBrickGrid(context, totalBricks, completedTasks, goalColor),
          ),
        ),
      ],
    );
  }

  Widget _buildStaggeredBrickGrid(
    BuildContext context,
    int totalBricks,
    List<TaskModel> completedTasks,
    Color goalColor,
  ) {
    const int bricksPerRow = 8;
    final int rowCount = (totalBricks / bricksPerRow).ceil();

    return Column(
      children: [
        // Rows from top (highest bricks) down to bottom (ground bricks 1, 2, 3...)
        ...List.generate(rowCount, (indexFromTop) {
          final int layerFromGround = rowCount - 1 - indexFromTop;
          final isEvenLayer = layerFromGround % 2 == 0;
          final startIdx = layerFromGround * bricksPerRow;
          final bricksInThisRow = (startIdx + bricksPerRow <= totalBricks)
              ? bricksPerRow
              : (totalBricks - startIdx);

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                // Stagger running bond pattern: alternate side indentation
                if (!isEvenLayer)
                  Container(
                    width: 14,
                    height: 28,
                    margin: const EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2D9D0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ...List.generate(bricksInThisRow, (colIndex) {
                  final brickIndex = startIdx + colIndex;
                  final isLaid = brickIndex < completedTasks.length;
                  final task = isLaid ? completedTasks[brickIndex] : null;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _showBrickDetails(context, brickIndex + 1, task, isLaid);
                      },
                      child: Container(
                        height: 28,
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        decoration: BoxDecoration(
                          color: isLaid ? goalColor : Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isLaid
                                ? goalColor.withValues(alpha: 0.8)
                                : const Color(0xFFD4CAC0),
                            width: 1,
                          ),
                          boxShadow: isLaid
                              ? [
                                  BoxShadow(
                                    color: goalColor.withValues(alpha: 0.3),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1.5),
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: isLaid
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : Text(
                                  "${brickIndex + 1}",
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFB0A49B),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  );
                }),
                if (isEvenLayer)
                  Container(
                    width: 14,
                    height: 28,
                    margin: const EdgeInsets.only(left: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2D9D0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          );
        }),
        // Ground foundation base
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(vertical: 4),
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF8C7D73),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(
            child: Text(
              "⛰️ GROUND LEVEL & FOUNDATION",
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Color(0xFFEBE5DF),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showBrickDetails(BuildContext context, int brickNum, TaskModel? task, bool isLaid) {
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isLaid ? Color(goal.colorValue) : const Color(0xFFEDE8E3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "🧱 #$brickNum",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isLaid ? Colors.white : const Color(0xFF6E635C),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLaid ? "Brick Solidly Laid!" : "Unbuilt Brick Slot",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isLaid ? "Goal: ${goal.title}" : "Awaiting Task Completion",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7A706A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (isLaid && task != null) ...[
                const Text(
                  "Laying Task:",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF7A706A)),
                ),
                const SizedBox(height: 4),
                Text(
                  task.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                if (task.description != null && task.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    task.description!,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF5E544E)),
                  ),
                ],
                if (task.completedAt != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    "Completed on: ${DateFormat('MMMM d, yyyy • h:mm a').format(task.completedAt!)}",
                    style: const TextStyle(fontSize: 11, color: Color(0xFF8F847D)),
                  ),
                ],
              ] else ...[
                const Text(
                  "This brick is still waiting to be laid! Complete any task assigned to this goal to cement this brick into the wall.",
                  style: TextStyle(fontSize: 13, color: Color(0xFF6E635C)),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E2420),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Got it"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
