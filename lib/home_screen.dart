import 'package:flutter/material.dart';

import 'item_model.dart';

class HomeScreen extends StatefulWidget {
  final List<Item> lowStockItems;
  final List<Item> groceryListItems;

  final Future<void> Function(Item item) onRestock;

  final Future<void> Function(
    Item oldItem, {
    required String name,
    required double currentQuantity,
    required String currentUnit,
    required double requiredQuantity,
    required String requiredUnit,
    required int peopleCount,
  })
  onUpdateItem;

  const HomeScreen({
    super.key,
    required this.lowStockItems,
    required this.groceryListItems,
    required this.onRestock,
    required this.onUpdateItem,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Stores the names of Grocery List items that are selected.
  final Set<String> selectedGroceryItems = {};

  static const int previewItemCount = 3;

  // ============================================================
  // HELPERS
  // ============================================================

  List<Item> get lowStockPreview {
    return widget.lowStockItems.take(previewItemCount).toList();
  }

  List<Item> get groceryPreview {
    return widget.groceryListItems.take(previewItemCount).toList();
  }

  bool isGroceryItemSelected(Item item) {
    return selectedGroceryItems.contains(item.name.trim().toLowerCase());
  }

  void toggleGroceryItem(Item item) {
    final key = item.name.trim().toLowerCase();

    setState(() {
      if (selectedGroceryItems.contains(key)) {
        selectedGroceryItems.remove(key);
      } else {
        selectedGroceryItems.add(key);
      }
    });
  }

  // ============================================================
  // RESTOCK ALL
  // ============================================================

  Future<void> restockAll() async {
    final Map<String, Item> itemsToRestock = {};

    // Add Low Stock items.
    for (final item in widget.lowStockItems) {
      itemsToRestock[item.name.trim().toLowerCase()] = item;
    }

    // Add Grocery List items.
    // Map automatically prevents duplicates.
    for (final item in widget.groceryListItems) {
      itemsToRestock[item.name.trim().toLowerCase()] = item;
    }

    if (itemsToRestock.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('No items to restock')));

      return;
    }

    final items = itemsToRestock.values.toList();

    final shouldRestock = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Restock All?',
            style: TextStyle(
              color: Color(0xFF315A39),
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Restock ${items.length} item${items.length == 1 ? '' : 's'} from Low Stock and Grocery List?',
            style: const TextStyle(color: Color(0xFF555555)),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext, false);
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      side: const BorderSide(color: Color(0xFFD5DDD1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Color(0xFF555555)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext, true);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      backgroundColor: const Color(0xFF4F8F5B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Restock'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (shouldRestock != true) {
      return;
    }

    for (final item in items) {
      await widget.onRestock(item);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      selectedGroceryItems.clear();
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'All items restocked',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(16, 0, 16, 90),
          duration: Duration(seconds: 2),
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool hasContent =
        widget.lowStockItems.isNotEmpty || widget.groceryListItems.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F1),
      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            const Padding(
              padding: EdgeInsets.only(top: 18, bottom: 8),
              child: Text(
                'Home Essentials',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF315A39),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =========================================
                    // LOW STOCK
                    // =========================================

                    _SectionHeader(
                      title: 'Low Stock',
                      description: widget.lowStockItems.isEmpty
                          ? 'Everything is sufficiently stocked'
                          : '${widget.lowStockItems.length} item${widget.lowStockItems.length == 1 ? '' : 's'} below required quantity',
                    ),

                    const SizedBox(height: 10),

                    if (lowStockPreview.isEmpty)
                      const _SectionEmptyState(
                        icon: Icons.check_circle_outline,
                        message: 'No low stock items',
                      )
                    else
                      ...lowStockPreview.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _PreviewItemCard(
                            item: item,
                            showTick: false,
                            onTap: () {
                              _showEditDialog(context, item);
                            },
                          ),
                        ),
                      ),

                    if (widget.lowStockItems.length > previewItemCount)
                      _ViewAllButton(
                        label: 'View All',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ItemListPage(
                                title: 'Low Stock',
                                items: widget.lowStockItems,
                                isGroceryList: false,
                                onRestock: widget.onRestock,
                                onUpdateItem: widget.onUpdateItem,
                                selectedGroceryItems: selectedGroceryItems,
                                onToggleGroceryItem: toggleGroceryItem,
                              ),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 24),

                    // =========================================
                    // GROCERY LIST
                    // =========================================
                    _SectionHeader(
                      title: 'Grocery List',
                      description: widget.groceryListItems.isEmpty
                          ? 'Your shopping list is empty'
                          : '${widget.groceryListItems.length} item${widget.groceryListItems.length == 1 ? '' : 's'} in your shopping list',
                    ),

                    const SizedBox(height: 10),

                    if (groceryPreview.isEmpty)
                      const _SectionEmptyState(
                        icon: Icons.shopping_cart_outlined,
                        message: 'Grocery List is empty',
                      )
                    else
                      ...groceryPreview.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _PreviewItemCard(
                            item: item,
                            showTick: true,
                            isSelected: isGroceryItemSelected(item),
                            onTickTap: () {
                              toggleGroceryItem(item);
                            },
                            onTap: () {
                              _showEditDialog(context, item);
                            },
                          ),
                        ),
                      ),

                    if (widget.groceryListItems.length > previewItemCount)
                      _ViewAllButton(
                        label: 'View All',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ItemListPage(
                                title: 'Grocery List',
                                items: widget.groceryListItems,
                                isGroceryList: true,
                                onRestock: widget.onRestock,
                                onUpdateItem: widget.onUpdateItem,
                                selectedGroceryItems: selectedGroceryItems,
                                onToggleGroceryItem: toggleGroceryItem,
                              ),
                            ),
                          );
                        },
                      ),

                    if (widget.groceryListItems.length <= previewItemCount &&
                        widget.groceryListItems.isNotEmpty)
                      const SizedBox(height: 4),

                    if (!hasContent) const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ==================================================
            // RESTOCK ALL
            // ==================================================
            if (widget.lowStockItems.isNotEmpty ||
                widget.groceryListItems.isNotEmpty)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: restockAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F8F5B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Restock All',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EDIT
  // ============================================================

  Future<void> _showEditDialog(BuildContext context, Item item) async {
    final result = await showDialog<_EditItemResult>(
      context: context,
      builder: (_) => _EditItemDialog(item: item),
    );

    if (result == null || !context.mounted) {
      return;
    }

    await widget.onUpdateItem(
      item,
      name: result.name,
      currentQuantity: result.currentQuantity,
      currentUnit: result.currentUnit,
      requiredQuantity: result.requiredQuantity,
      requiredUnit: result.requiredUnit,
      peopleCount: 2,
    );
  }
}

// ============================================================
// SECTION HEADER
// ============================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final String description;

  const _SectionHeader({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF315A39),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          description,
          style: const TextStyle(color: Color(0xFF777777), fontSize: 12),
        ),
      ],
    );
  }
}

// ============================================================
// PREVIEW ITEM CARD
// ============================================================

class _PreviewItemCard extends StatelessWidget {
  final Item item;
  final bool showTick;
  final bool isSelected;

  final VoidCallback onTap;
  final VoidCallback? onTickTap;

  const _PreviewItemCard({
    required this.item,
    required this.showTick,
    this.isSelected = false,
    required this.onTap,
    this.onTickTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE0E6DC)),
          ),
          child: Row(
            children: [
              _ItemImage(name: item.name, size: 44),

              const SizedBox(width: 11),

              Expanded(
                child: Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF315A39),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Text(
                '${_formatQuantity(item.currentQuantity)} ${item.currentUnit}',
                style: const TextStyle(
                  color: Color(0xFF555555),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),

              if (showTick) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onTickTap,
                  child: Container(
                    width: 27,
                    height: 27,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? const Color(0xFF4F8F5B)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4F8F5B)
                            : const Color(0xFFB9C5B5),
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 17, color: Colors.white)
                        : null,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// VIEW ALL BUTTON
// ============================================================

class _ViewAllButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ViewAllButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF4F8F5B),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _SectionEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _SectionEmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E6DC)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF4F8F5B), size: 20),
          const SizedBox(width: 8),
          Text(
            message,
            style: const TextStyle(color: Color(0xFF777777), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// IMAGE
// ============================================================

class _ItemImage extends StatelessWidget {
  final String name;
  final double size;

  const _ItemImage({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    final query = Uri.encodeComponent('$name food');

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        'https://loremflickr.com/160/160/$query',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            color: const Color(0xFFE7F1DF),
            child: Icon(
              Icons.shopping_basket_outlined,
              color: const Color(0xFF4F8F5B),
              size: size * 0.48,
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// FULL LIST PAGE
// ============================================================

class ItemListPage extends StatefulWidget {
  final String title;
  final List<Item> items;
  final bool isGroceryList;

  final Future<void> Function(Item item) onRestock;

  final Future<void> Function(
    Item oldItem, {
    required String name,
    required double currentQuantity,
    required String currentUnit,
    required double requiredQuantity,
    required String requiredUnit,
    required int peopleCount,
  })
  onUpdateItem;

  final Set<String> selectedGroceryItems;

  final void Function(Item item) onToggleGroceryItem;

  const ItemListPage({
    super.key,
    required this.title,
    required this.items,
    required this.isGroceryList,
    required this.onRestock,
    required this.onUpdateItem,
    required this.selectedGroceryItems,
    required this.onToggleGroceryItem,
  });

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8F1),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Color(0xFF315A39),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: widget.items.isEmpty
          ? const _SectionEmptyState(
              icon: Icons.inventory_2_outlined,
              message: 'No items',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              itemCount: widget.items.length,
              separatorBuilder: (_, index) => const SizedBox(height: 9),
              itemBuilder: (context, index) {
                final item = widget.items[index];

                return _FullItemCard(
                  item: item,
                  showTick: widget.isGroceryList,
                  isSelected: widget.selectedGroceryItems.contains(
                    item.name.trim().toLowerCase(),
                  ),
                  onTickTap: widget.isGroceryList
                      ? () {
                          widget.onToggleGroceryItem(item);
                          setState(() {});
                        }
                      : null,
                  onTap: () {
                    _showEditDialog(context, item);
                  },
                  onRestock: () {
                    _showRestockConfirmation(context, item);
                  },
                );
              },
            ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, Item item) async {
    final result = await showDialog<_EditItemResult>(
      context: context,
      builder: (_) => _EditItemDialog(item: item),
    );

    if (result == null || !context.mounted) {
      return;
    }

    await widget.onUpdateItem(
      item,
      name: result.name,
      currentQuantity: result.currentQuantity,
      currentUnit: result.currentUnit,
      requiredQuantity: result.requiredQuantity,
      requiredUnit: result.requiredUnit,
      peopleCount: 2,
    );

    if (mounted) {
      setState(() {});
    }
  }

  void _showRestockConfirmation(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Restock Item?',
            style: TextStyle(
              color: Color(0xFF315A39),
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Restock ${item.name} to the required quantity?',
            style: const TextStyle(color: Color(0xFF555555)),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      side: const BorderSide(color: Color(0xFFD5DDD1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Color(0xFF555555)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext);

                      await widget.onRestock(item);

                      if (mounted) {
                        setState(() {});
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      backgroundColor: const Color(0xFF4F8F5B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Restock'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// FULL ITEM CARD
// ============================================================

class _FullItemCard extends StatelessWidget {
  final Item item;
  final bool showTick;
  final bool isSelected;

  final VoidCallback onTap;
  final VoidCallback? onTickTap;
  final VoidCallback onRestock;

  const _FullItemCard({
    required this.item,
    required this.showTick,
    required this.isSelected,
    required this.onTap,
    required this.onTickTap,
    required this.onRestock,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E6DC)),
          ),
          child: Row(
            children: [
              _ItemImage(name: item.name, size: 56),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF315A39),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Current: ${_formatQuantity(item.currentQuantity)} ${item.currentUnit}',
                      style: const TextStyle(
                        color: Color(0xFF555555),
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      'Required: ${_formatQuantity(item.requiredQuantity)} ${item.requiredUnit}',
                      style: const TextStyle(
                        color: Color(0xFF777777),
                        fontSize: 12,
                      ),
                    ),

                    if (item.previousQuantity != null &&
                        item.previousUnit != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Previous: ${_formatQuantity(item.previousQuantity!)} ${item.previousUnit}',
                        style: const TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (showTick)
                GestureDetector(
                  onTap: onTickTap,
                  child: Container(
                    width: 29,
                    height: 29,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? const Color(0xFF4F8F5B)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4F8F5B)
                            : const Color(0xFFB9C5B5),
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : null,
                  ),
                )
              else
                IconButton(
                  onPressed: onRestock,
                  icon: const Icon(
                    Icons.add_shopping_cart,
                    color: Color(0xFF4F8F5B),
                    size: 22,
                  ),
                  tooltip: 'Restock',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EDIT RESULT
// ============================================================

class _EditItemResult {
  final String name;
  final double currentQuantity;
  final String currentUnit;
  final double requiredQuantity;
  final String requiredUnit;

  const _EditItemResult({
    required this.name,
    required this.currentQuantity,
    required this.currentUnit,
    required this.requiredQuantity,
    required this.requiredUnit,
  });
}

// ============================================================
// EDIT DIALOG
// ============================================================

class _EditItemDialog extends StatefulWidget {
  final Item item;

  const _EditItemDialog({required this.item});

  @override
  State<_EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<_EditItemDialog> {
  late final TextEditingController nameController;

  late final TextEditingController currentQuantityController;

  late final TextEditingController requiredQuantityController;

  late String currentUnit;
  late String requiredUnit;

  static const List<String> units = [
    'kg',
    'g',
    'litres',
    'ml',
    'pieces',
    'packets',
  ];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.item.name);

    currentQuantityController = TextEditingController(
      text: _formatQuantity(widget.item.currentQuantity),
    );

    requiredQuantityController = TextEditingController(
      text: _formatQuantity(widget.item.requiredQuantity),
    );

    currentUnit = widget.item.currentUnit;

    requiredUnit = widget.item.requiredUnit;
  }

  @override
  void dispose() {
    nameController.dispose();
    currentQuantityController.dispose();
    requiredQuantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Edit Item',
        style: TextStyle(color: Color(0xFF315A39), fontWeight: FontWeight.w700),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: currentQuantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Current Quantity',
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: currentUnit,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    items: units
                        .map(
                          (unit) =>
                              DropdownMenuItem(value: unit, child: Text(unit)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          currentUnit = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: requiredQuantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Required Quantity',
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: requiredUnit,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    items: units
                        .map(
                          (unit) =>
                              DropdownMenuItem(value: unit, child: Text(unit)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          requiredUnit = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  side: const BorderSide(color: Color(0xFFD5DDD1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF555555)),
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  backgroundColor: const Color(0xFF4F8F5B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _save() {
    final name = nameController.text.trim();

    final currentQuantity = double.tryParse(
      currentQuantityController.text.trim(),
    );

    final requiredQuantity = double.tryParse(
      requiredQuantityController.text.trim(),
    );

    if (name.isEmpty ||
        currentQuantity == null ||
        requiredQuantity == null ||
        currentQuantity < 0 ||
        requiredQuantity < 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Please enter valid values')),
        );

      return;
    }

    Navigator.pop(
      context,
      _EditItemResult(
        name: name,
        currentQuantity: currentQuantity,
        currentUnit: currentUnit,
        requiredQuantity: requiredQuantity,
        requiredUnit: requiredUnit,
      ),
    );
  }
}

// ============================================================
// QUANTITY FORMAT
// ============================================================

String _formatQuantity(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value.toStringAsFixed(2);
}
