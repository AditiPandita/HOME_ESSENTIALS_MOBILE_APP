import 'package:flutter/material.dart';

import 'history_entry.dart';

class HistoryScreen extends StatelessWidget {
  final List<HistoryEntry> history;

  const HistoryScreen({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final entries = history.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: entries.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                14,
                12,
                14,
                100,
              ),
              itemCount: entries.length,
              separatorBuilder: (
                context,
                index,
              ) =>
                  const SizedBox(height: 9),
              itemBuilder: (
                context,
                index,
              ) {
                return _buildHistoryCard(
                  context,
                  entries[index],
                );
              },
            ),
    );
  }

  // ============================================================
  // HISTORY CARD
  // ============================================================

  Widget _buildHistoryCard(
    BuildContext context,
    HistoryEntry entry,
  ) {
    final bool isRestock =
        entry.action.toLowerCase().contains(
              'restock',
            );

    final bool isAdded =
        entry.action.toLowerCase().contains(
              'added',
            );

    IconData icon = Icons.edit_outlined;

    if (isRestock) {
      icon = Icons.refresh_rounded;
    } else if (isAdded) {
      icon = Icons.add_box_outlined;
    }

    String quantityText = '';

    if (entry.oldQuantity != null &&
        entry.newQuantity != null) {
      quantityText =
          '${_formatNumber(entry.oldQuantity!)} '
          '${entry.oldUnit ?? ''} → '
          '${_formatNumber(entry.newQuantity!)} '
          '${entry.newUnit ?? ''}';
    } else if (entry.newQuantity != null) {
      quantityText =
          '${_formatNumber(entry.newQuantity!)} '
          '${entry.newUnit ?? ''}';
    } else if (entry.oldQuantity != null) {
      quantityText =
          '${_formatNumber(entry.oldQuantity!)} '
          '${entry.oldUnit ?? ''}';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.88,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8ECE3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0B000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isRestock
                    ? const Color(0xFFEAF4E6)
                    : const Color(0xFFF1F3E9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 21,
                color: const Color(0xFF56885D),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.itemName,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          Color(0xFF303930),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    entry.action,
                    style: const TextStyle(
                      fontSize: 12,
                      color:
                          Color(0xFF747B74),
                    ),
                  ),

                  if (quantityText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      quantityText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w600,
                        color:
                            Color(0xFF4F6552),
                      ),
                    ),
                  ],

                  const SizedBox(height: 5),

                  Text(
                    _formatDateTime(
                      entry.dateTime,
                    ),
                    style: const TextStyle(
                      fontSize: 10,
                      color:
                          Color(0xFF929892),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 100,
              decoration: BoxDecoration(
                color:
                    const Color(0xFFEFF5E8),
                borderRadius:
                    BorderRadius.circular(55),
              ),
              child: const Icon(
                Icons.history_outlined,
                size: 52,
                color: Color(0xFF6A9A69),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No history yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.w700,
                color:
                    Color(0xFF334137),
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Your item additions, edits and restocks\n'
              'will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                height: 1.4,
                color:
                    Color(0xFF777E77),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value
        .toStringAsFixed(2)
        .replaceFirst(
          RegExp(r'0+$'),
          '',
        )
        .replaceFirst(
          RegExp(r'\.$'),
          '',
        );
  }

  String _formatDateTime(
    DateTime dateTime,
  ) {
    final local = dateTime.toLocal();

    final hour12 = local.hour == 0
        ? 12
        : local.hour > 12
            ? local.hour - 12
            : local.hour;

    final minute =
        local.minute.toString().padLeft(2, '0');

    final period =
        local.hour >= 12 ? 'PM' : 'AM';

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}  '
        '$hour12:$minute $period';
  }
}