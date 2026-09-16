import 'package:flutter/material.dart';

import 'item_model.dart';

class AddItemScreen extends StatefulWidget {
  final List<Item> items;

  final Future<void> Function(Item item) onItemAdded;

  final Future<void> Function(Item item) onAddToHome;

  final Future<void> Function(
    Item oldItem, {
    required String name,
    required double currentQuantity,
    required String currentUnit,
    required double requiredQuantity,
    required String requiredUnit,
    required int peopleCount,
  }) onItemEdited;

  final Future<void> Function(Item item) onItemDeleted;

  const AddItemScreen({
    super.key,
    required this.items,
    required this.onItemAdded,
    required this.onAddToHome,
    required this.onItemEdited,
    required this.onItemDeleted,
  });

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  // ============================================================
  // IMAGE
  // ============================================================

  String _imageUrl(String name) {
    final query = Uri.encodeComponent('$name food');
    return 'https://loremflickr.com/160/160/$query';
  }

  Widget _itemImage(Item item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: Container(
        width: 50,
        height: 50,
        color: const Color(0xFFF1F3E9),
        child: Image.network(
          _imageUrl(item.name),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.shopping_basket_outlined,
              color: Color(0xFF5C8F62),
              size: 27,
            );
          },
          loadingBuilder: (
            context,
            child,
            loadingProgress,
          ) {
            if (loadingProgress == null) {
              return child;
            }

            return const Icon(
              Icons.shopping_basket_outlined,
              color: Color(0xFF5C8F62),
              size: 27,
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // ADD POPUP
  // ============================================================

  Future<void> _openAddPopup() async {
    final Item? item = await showDialog<Item>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return const _AddItemDialog();
      },
    );

    // IMPORTANT:
    // The dialog is completely closed before this runs.
    if (!mounted || item == null) {
      return;
    }

    await widget.onItemAdded(item);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Item added successfully',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            90,
          ),
          duration: Duration(seconds: 2),
        ),
      );
  }

  // ============================================================
  // INVENTORY CARD
  // ============================================================

  Widget _buildInventoryCard(Item item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8ECE3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        child: Row(
          children: [
            _itemImage(item),

            const SizedBox(width: 11),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF303930),
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    '${_formatNumber(item.currentQuantity)} '
                    '${item.currentUnit}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF747B74),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 6),

            if (item.isLowStock)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1DC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Low',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB56A1D),
                  ),
                ),
              ),

            const SizedBox(width: 6),

            Material(
              color: const Color(0xFF5D9664),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () async {
                  await widget.onAddToHome(item);

                  if (!mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          '${item.name} added to Home',
                        ),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          90,
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                },
                child: const SizedBox(
                  width: 30,
                  height: 30,
                  child: Icon(
                    Icons.add,
                    size: 19,
                    color: Colors.white,
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
  // EMPTY INVENTORY
  // ============================================================

  Widget _buildEmptyInventory() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 105,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF5E8),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Center(
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 60,
                  color: Color(0xFF6A9A69),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No items added',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334137),
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Start adding groceries, kitchen essentials\n'
              'and other items to keep track easily!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                height: 1.4,
                color: Color(0xFF777E77),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inventory',
        ),
      ),

      body: widget.items.isEmpty
          ? _buildEmptyInventory()
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                12,
                8,
                12,
                100,
              ),
              children: [
                ...widget.items.map(
                  _buildInventoryCard,
                ),
              ],
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: _openAddPopup,
        backgroundColor: const Color(0xFF5D9664),
        foregroundColor: Colors.white,
        elevation: 5,
        child: const Icon(
          Icons.add,
          size: 28,
        ),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
    );
  }

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
}

// ================================================================
// ADD ITEM DIALOG
// ================================================================

class _AddItemDialog extends StatefulWidget {
  const _AddItemDialog();

  @override
  State<_AddItemDialog> createState() =>
      _AddItemDialogState();
}

class _AddItemDialogState
    extends State<_AddItemDialog> {
  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController currentController =
      TextEditingController();

  final TextEditingController requiredController =
      TextEditingController();

  String currentUnit = 'kg';
  String requiredUnit = 'kg';

  static const List<String> units = [
    'kg',
    'g',
    'litres',
    'ml',
    'pieces',
    'packets',
  ];

  @override
  void dispose() {
    nameController.dispose();
    currentController.dispose();
    requiredController.dispose();

    super.dispose();
  }

  // ============================================================
  // ADD
  // ============================================================

  void _addItem() {
    final String name =
        nameController.text.trim();

    final double? current =
        double.tryParse(
      currentController.text.trim(),
    );

    final double? required =
        double.tryParse(
      requiredController.text.trim(),
    );

    if (name.isEmpty ||
        current == null ||
        required == null ||
        current < 0 ||
        required < 0) {
      ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter valid details.',
          ),
        ),
      );

      return;
    }

    final Item item = Item(
      name: name,
      currentQuantity: current,
      currentUnit: currentUnit,
      requiredQuantity: required,
      requiredUnit: requiredUnit,
      peopleCount: 2,
      lastConsumptionDate:
          Item.dateOnly(
        DateTime.now(),
      ),
    );

    // IMPORTANT:
    // Return the item from the dialog.
    // Do NOT call the parent callback here.
    Navigator.of(context).pop(item);
  }

  // ============================================================
  // BUILD DIALOG
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFFFFEF8),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),

      title: const Text(
        'Add Item',
        style: TextStyle(
          color: Color(0xFF315A39),
          fontWeight: FontWeight.w700,
        ),
      ),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ----------------------------------------------------
            // ITEM NAME
            // ----------------------------------------------------

            TextField(
              controller: nameController,
              textCapitalization:
                  TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                hintText: 'e.g. Rice',
              ),
            ),

            const SizedBox(height: 14),

            // ----------------------------------------------------
            // CURRENT QUANTITY
            // ----------------------------------------------------

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller:
                        currentController,
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Current Quantity',
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child:
                      DropdownButtonFormField<String>(
                    initialValue: currentUnit,

                    decoration:
                        const InputDecoration(
                      labelText: 'Unit',
                    ),

                    items: units.map(
                      (unit) {
                        return DropdownMenuItem<
                            String>(
                          value: unit,
                          child: Text(unit),
                        );
                      },
                    ).toList(),

                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        currentUnit = value;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ----------------------------------------------------
            // REQUIRED QUANTITY
            // ----------------------------------------------------

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller:
                        requiredController,
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Required Quantity',
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child:
                      DropdownButtonFormField<String>(
                    initialValue: requiredUnit,

                    decoration:
                        const InputDecoration(
                      labelText: 'Unit',
                    ),

                    items: units.map(
                      (unit) {
                        return DropdownMenuItem<
                            String>(
                          value: unit,
                          child: Text(unit),
                        );
                      },
                    ).toList(),

                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        requiredUnit = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // ==========================================================
      // BUTTONS
      // ==========================================================

      actionsPadding:
          const EdgeInsets.fromLTRB(
        20,
        4,
        20,
        20,
      ),

      actions: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style:
                      OutlinedButton.styleFrom(
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _addItem,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF4F8F5B,
                    ),
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Add',
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}