import 'package:flutter/material.dart';

import 'item_model.dart';

class HomeScreen extends StatelessWidget {
  final List<Item> items;

  const HomeScreen({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final List<Item> lowStockItems =
        items.where((item) => item.isLowStock).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Low Stock'),
      ),
      body: lowStockItems.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              children: [
                ...lowStockItems.map(_buildItemCard),
              ],
            ),
    );
  }

  Widget _buildItemCard(Item item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Available Quantity: '
              '${_formatNumber(item.currentQuantity)} ${item.unit}',
            ),
            const SizedBox(height: 3),
            Text(
              'Required Quantity: '
              '${_formatNumber(item.requiredQuantity)} ${item.unit}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 56,
            ),
            SizedBox(height: 14),
            Text(
              'No items are running low.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }
}
