import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/track_provider.dart';
import '../../models/track_model.dart';
import '../../widgets/add_track_item_dialog.dart';
import '../../widgets/add_track_entry_dialog.dart';

class TrackingTab extends StatefulWidget {
  const TrackingTab({super.key});

  @override
  State<TrackingTab> createState() => _TrackingTabState();
}

class _TrackingTabState extends State<TrackingTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trackProvider = Provider.of<TrackProvider>(context);
    final items = trackProvider.items;
    final selectedItem = trackProvider.selectedItem;
    final entries = trackProvider.entriesForSelectedItem;

    if (trackProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFD84315).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Text("📊", style: TextStyle(fontSize: 48)),
              ),
              const SizedBox(height: 20),
              const Text(
                "Start Tracking Your Behavior",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E2420),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Create custom tracking categories like Health, Sleep, Focus, or Workouts, and log notes inside each.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF756A63)),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => AddTrackItemDialog.show(context),
                icon: const Icon(Icons.add),
                label: const Text("Create First Tracker"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD84315),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final color = selectedItem != null ? Color(selectedItem.colorValue) : const Color(0xFFD84315);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // 1. Horizontal Scrollable Tabs of Track Items
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Add New Tracker Button
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => AddTrackItemDialog.show(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFD7CCC8)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, size: 16, color: Color(0xFFD84315)),
                          SizedBox(width: 4),
                          Text(
                            "New Tracker",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD84315),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Track Item Pills
                  ...items.map((item) {
                    final isSelected = item.id == selectedItem?.id;
                    final count = trackProvider.getEntryCountForItem(item.id);
                    final itemColor = Color(item.colorValue);

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          _searchController.clear();
                          trackProvider.selectItem(item.id);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? itemColor : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? itemColor : const Color(0xFFE2DDD7),
                              width: isSelected ? 1.5 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: itemColor.withValues(alpha: 0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Text(item.icon, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: isSelected ? Colors.white : const Color(0xFF4A403A),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.3)
                                      : const Color(0xFFF2ECE6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "$count",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : const Color(0xFF756A63),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // 2. Active Tracker Header Card
          if (selectedItem != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: color.withValues(alpha: 0.25), width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(selectedItem.icon, style: const TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedItem.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E2420),
                              ),
                            ),
                            if (selectedItem.description.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                selectedItem.description,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF756A63)),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              "${entries.length} tracked note${entries.length == 1 ? '' : 's'}",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFF756A63)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onSelected: (val) {
                          if (val == 'edit') {
                            AddTrackItemDialog.show(context, existingItem: selectedItem);
                          } else if (val == 'delete') {
                            _confirmDeleteTracker(context, selectedItem);
                          }
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 18, color: Color(0xFF4A403A)),
                                SizedBox(width: 8),
                                Text("Edit Tracker", style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text("Delete Tracker", style: TextStyle(fontSize: 13, color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 3. Search Bar within Current Tracker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => trackProvider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: "Search in ${selectedItem?.title ?? 'tracker'}...",
                hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9E928A)),
                prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF9E928A)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          trackProvider.setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2DDD7)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2DDD7)),
                ),
              ),
            ),
          ),

          // 4. Notes / Log Entries Feed
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.note_alt_outlined, size: 48, color: Colors.brown.shade200),
                          const SizedBox(height: 12),
                          Text(
                            _searchController.text.isNotEmpty
                                ? "No matching notes found"
                                : "No notes in ${selectedItem?.title ?? 'this tracker'} yet",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A403A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _searchController.text.isNotEmpty
                                ? "Try a different search query"
                                : "Tap '+ Log Note' below to record habits, behaviors, or observations.",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF8D8076)),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 80),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _buildEntryCard(context, entry, color);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: selectedItem != null
          ? FloatingActionButton.extended(
              onPressed: () => AddTrackEntryDialog.show(
                context,
                trackItemId: selectedItem.id,
              ),
              backgroundColor: color,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: Text("Log in ${selectedItem.title}"),
            )
          : null,
    );
  }

  Widget _buildEntryCard(BuildContext context, TrackEntryModel entry, Color themeColor) {
    final trackProvider = Provider.of<TrackProvider>(context, listen: false);
    final formattedDate = _formatTimestamp(entry.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFEBE5DF), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row with timestamp, tag, rating, and menu
            Row(
              children: [
                Icon(Icons.schedule, size: 14, color: themeColor),
                const SizedBox(width: 4),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
                if (entry.tag != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2ECE6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      entry.tag!,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5D5047),
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (entry.rating != null) ...[
                  Row(
                    children: List.generate(entry.rating!, (i) => const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Color(0xFFFFB300),
                    )),
                  ),
                  const SizedBox(width: 4),
                ],
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz, size: 18, color: Color(0xFF8D8076)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onSelected: (val) {
                    if (val == 'edit') {
                      AddTrackEntryDialog.show(
                        context,
                        trackItemId: entry.trackItemId,
                        existingEntry: entry,
                      );
                    } else if (val == 'delete') {
                      trackProvider.deleteTrackEntry(entry.id);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 16),
                          SizedBox(width: 6),
                          Text("Edit", style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 16, color: Colors.red),
                          SizedBox(width: 6),
                          Text("Delete", style: TextStyle(fontSize: 13, color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              entry.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E2420),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              entry.content,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF4A403A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final isYesterday = dt.year == now.year && dt.month == now.month && dt.day == now.day - 1;

    final timeStr = DateFormat('h:mm a').format(dt);

    if (isToday) return "Today • $timeStr";
    if (isYesterday) return "Yesterday • $timeStr";
    return "${DateFormat('MMM d, yyyy').format(dt)} • $timeStr";
  }

  void _confirmDeleteTracker(BuildContext context, TrackItemModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete '${item.title}'?"),
        content: const Text(
          "This will delete this tracker and all notes recorded inside it. This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Provider.of<TrackProvider>(context, listen: false).deleteTrackItem(item.id);
              Navigator.pop(ctx);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}

