import 'package:flutter/material.dart';

import 'api_service.dart';
import 'item_model.dart';

class AddItemPage extends StatefulWidget {
  final List<Item> items;
  final void Function(Item item) onItemAdded;
  final void Function(Item item, double addedQuantity) onItemRestocked;
  final Future<void> Function(Item oldItem, Item newItem) onItemEdited;
  final void Function(Item item) onItemDeleted;

  const AddItemPage({
    super.key,
    required this.items,
    required this.onItemAdded,
    required this.onItemRestocked,
    required this.onItemEdited,
    required this.onItemDeleted,
  });

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final ApiService _apiService = ApiService();

  bool _isLoadingSuggestions = false;
  String? _apiError;
  List<ApiProduct> _suggestions = [];

  static const List<String> _commonCategories = [
    'en:milks',
    'en:breads',
    'en:rice',
    'en:sugars',
  ];

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    if (_isLoadingSuggestions) return;

    setState(() {
      _isLoadingSuggestions = true;
      _apiError = null;
    });

    try {
      final List<ApiProduct> allProducts = [];
      final Set<String> seenNames = {};

      for (final category in _commonCategories) {
        try {
          final List<ApiProduct> products =
              await _apiService.searchProducts(category);

          for (final ApiProduct product in products) {
            final String key = product.name.trim().toLowerCase();

            if (key.isNotEmpty && seenNames.add(key)) {
              allProducts.add(product);
            }

            if (allProducts.length >= 12) {
              break;
            }
          }
        } catch (_) {
          // Continue with the next category.
        }

        if (allProducts.length >= 12) {
          break;
        }
      }

      if (!mounted) return;

      setState(() {
        _suggestions = allProducts.take(12).toList();
        _isLoadingSuggestions = false;

        if (_suggestions.isEmpty) {
          _apiError = 'Could not load suggestions right now.';
        }
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingSuggestions = false;
        _apiError = 'Could not load suggestions right now.';
      });
    }
  }

  Future<void> _openAddPopup({
    String initialName = '',
    String initialCategory = 'Food',
  }) async {
    final Item? newItem = await showDialog<Item>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _ItemFormDialog(
          title: 'Add Item',
          initialName: initialName,
          initialCategory: initialCategory,
        );
      },
    );

    if (!mounted || newItem == null) return;

    widget.onItemAdded(newItem);
  }

  Future<void> _openRestockPopup(Item item) async {
    final double? addedQuantity = await showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _RestockDialog(item: item);
      },
    );

    if (!mounted || addedQuantity == null || addedQuantity <= 0) {
      return;
    }

    widget.onItemRestocked(item, addedQuantity);
  }

  Future<void> _openEditPopup(Item item) async {
    final Item? editedItem = await showDialog<Item>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _ItemFormDialog(
          title: 'Edit Item',
          initialItem: item,
        );
      },
    );

    if (!mounted || editedItem == null) return;

    await widget.onItemEdited(item, editedItem);
  }

  Future<void> _openDeletePopup(Item item) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _DeleteDialog(item: item);
      },
    );

    if (!mounted || shouldDelete != true) return;

    widget.onItemDeleted(item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Items'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSuggestions,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            _buildAddCustomCard(),
            const SizedBox(height: 20),
            _buildSuggestionsSection(),
            const SizedBox(height: 24),
            _buildInventorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCustomCard() {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _openAddPopup,
        child: const Padding(
          padding: EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                child: Icon(Icons.add),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Custom Item',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Add any grocery or household item manually.',
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Common Items',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Suggestions from the product database',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        if (_isLoadingSuggestions)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_apiError != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.cloud_off, size: 36),
                  const SizedBox(height: 8),
                  Text(
                    _apiError!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _loadSuggestions,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else if (_suggestions.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No suggestions available. You can add a custom item.',
              ),
            ),
          )
        else
          ..._suggestions.map(_buildSuggestionCard),
      ],
    );
  }

  Widget _buildSuggestionCard(ApiProduct product) {
    final bool alreadyAdded = widget.items.any(
      (item) =>
          item.name.trim().toLowerCase() ==
          product.name.trim().toLowerCase(),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.shopping_basket),
        ),
        title: Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          product.brand.isEmpty
              ? 'Food'
              : '${product.brand} • Food',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: alreadyAdded
            ? const Icon(Icons.check_circle)
            : const Icon(Icons.add_circle_outline),
        onTap: alreadyAdded
            ? null
            : () => _openAddPopup(
                  initialName: product.name,
                  initialCategory: 'Food',
                ),
      ),
    );
  }

  Widget _buildInventorySection() {
    if (widget.items.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.inventory_2_outlined, size: 48),
              SizedBox(height: 10),
              Text(
                'No items in inventory yet.',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Add an item to start tracking your household stock.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inventory',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...widget.items.map(_buildInventoryCard),
      ],
    );
  }

  Widget _buildInventoryCard(Item item) {
    final double days = item.estimatedDaysRemaining;
    final String daysText = days.isInfinite
        ? 'No consumption rate'
        : '${days.toStringAsFixed(1)} days remaining';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (item.isLowStock)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context)
                          .colorScheme
                          .errorContainer,
                    ),
                    child: Text(
                      'Low Stock',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onErrorContainer,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Category: ${item.category}'),
            const SizedBox(height: 4),
            Text(
              'Current Quantity: '
              '${_formatNumber(item.currentQuantity)} ${item.unit}',
            ),
            Text(
              'Required Quantity: '
              '${_formatNumber(item.requiredQuantity)} ${item.unit}',
            ),
            const SizedBox(height: 4),
            Text(
              'Daily consumption: '
              '${_formatNumber(item.dailyConsumption)} ${item.unit}',
            ),
            Text(daysText),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => _openRestockPopup(item),
                  icon: const Icon(Icons.add),
                  label: const Text('Restock'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _openEditPopup(item),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _openDeletePopup(item),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ],
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

class _ItemFormDialog extends StatefulWidget {
  final String title;
  final Item? initialItem;
  final String initialName;
  final String initialCategory;

  const _ItemFormDialog({
    required this.title,
    this.initialItem,
    this.initialName = '',
    this.initialCategory = 'Food',
  });

  @override
  State<_ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<_ItemFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _currentQuantityController;
  late final TextEditingController _requiredQuantityController;
  late final TextEditingController _peopleController;
  late final TextEditingController _quantityPerPersonController;
  late final TextEditingController _timesPerDayController;

  late String _selectedCategory;
  late String _selectedUnit;

  static const List<String> _categories = [
    'Food',
    'Groceries',
    'Personal Care',
    'Cleaning',
    'Household',
    'Other',
  ];

  static const List<String> _units = [
    'pieces',
    'kg',
    'g',
    'litres',
    'ml',
    'packets',
    'bottles',
    'boxes',
  ];

  @override
  void initState() {
    super.initState();

    final Item? item = widget.initialItem;

    _nameController = TextEditingController(
      text: item?.name ?? widget.initialName,
    );

    _currentQuantityController = TextEditingController(
      text: item == null ? '' : _formatNumber(item.currentQuantity),
    );

    _requiredQuantityController = TextEditingController(
      text: item == null ? '' : _formatNumber(item.requiredQuantity),
    );

    _peopleController = TextEditingController(
      text: item?.peopleCount.toString() ?? '1',
    );

    _quantityPerPersonController = TextEditingController(
      text: item == null
          ? ''
          : _formatNumber(item.quantityPerPerson),
    );

    _timesPerDayController = TextEditingController(
      text: item?.timesPerDay.toString() ?? '1',
    );

    _selectedCategory = _categories.contains(item?.category)
        ? item!.category
        : (widget.initialCategory.isNotEmpty &&
                _categories.contains(widget.initialCategory)
            ? widget.initialCategory
            : 'Food');

    _selectedUnit = _units.contains(item?.unit)
        ? item!.unit
        : 'pieces';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentQuantityController.dispose();
    _requiredQuantityController.dispose();
    _peopleController.dispose();
    _quantityPerPersonController.dispose();
    _timesPerDayController.dispose();
    super.dispose();
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }

  String? _doubleValidator(
    String? value, {
    required String fieldName,
    bool positive = false,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final double? number = double.tryParse(value.trim());

    if (number == null) {
      return 'Enter a valid number';
    }

    if (number < 0) {
      return '$fieldName cannot be negative';
    }

    if (positive && number <= 0) {
      return '$fieldName must be greater than 0';
    }

    return null;
  }

  String? _intValidator(
    String? value, {
    required String fieldName,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final int? number = int.tryParse(value.trim());

    if (number == null || number <= 0) {
      return '$fieldName must be a whole number greater than 0';
    }

    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final Item? oldItem = widget.initialItem;

    final Item item = Item(
      name: _nameController.text.trim(),
      category: _selectedCategory,
      currentQuantity:
          double.parse(_currentQuantityController.text.trim()),
      requiredQuantity:
          double.parse(_requiredQuantityController.text.trim()),
      unit: _selectedUnit,
      peopleCount: int.parse(_peopleController.text.trim()),
      quantityPerPerson:
          double.parse(_quantityPerPersonController.text.trim()),
      timesPerDay: int.parse(_timesPerDayController.text.trim()),
      lastConsumptionDate:
          oldItem?.lastConsumptionDate ??
              Item.dateOnly(DateTime.now()),
    );

    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.initialItem != null;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 520,
          maxHeight: 720,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Item Name',
                          hintText: 'e.g. Milk',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Item name is required';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: _categories
                            .map(
                              (category) =>
                                  DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedUnit,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(),
                        ),
                        items: _units
                            .map(
                              (unit) => DropdownMenuItem<String>(
                                value: unit,
                                child: Text(unit),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() {
                            _selectedUnit = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _currentQuantityController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Current Quantity',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => _doubleValidator(
                          value,
                          fieldName: 'Current quantity',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _requiredQuantityController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Required Quantity',
                          hintText: 'Minimum stock needed',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => _doubleValidator(
                          value,
                          fieldName: 'Required quantity',
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Automatic Consumption',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'The app automatically estimates daily '
                          'consumption. No manual Consume button is needed.',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _peopleController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Number of People',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => _intValidator(
                          value,
                          fieldName: 'Number of people',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller:
                            _quantityPerPersonController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Quantity Per Person',
                          suffixText: _selectedUnit,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) => _doubleValidator(
                          value,
                          fieldName: 'Quantity per person',
                          positive: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _timesPerDayController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Times Per Day',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => _intValidator(
                          value,
                          fieldName: 'Times per day',
                        ),
                        onFieldSubmitted: (_) => _save(),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _save,
                        child: Text(
                          isEditing
                              ? 'Save Changes'
                              : 'Add Item',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _RestockDialog extends StatefulWidget {
  final Item item;

  const _RestockDialog({
    required this.item,
  });

  @override
  State<_RestockDialog> createState() => _RestockDialogState();
}

class _RestockDialogState extends State<_RestockDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double quantity =
        double.parse(_quantityController.text.trim());

    Navigator.of(context).pop(quantity);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Restock Item'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _quantityController,
          autofocus: true,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Quantity to Add',
            suffixText: widget.item.unit,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Quantity is required';
            }

            final double? number =
                double.tryParse(value.trim());

            if (number == null || number <= 0) {
              return 'Enter a quantity greater than 0';
            }

            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Restock'),
        ),
      ],
    );
  }
}

class _DeleteDialog extends StatelessWidget {
  final Item item;

  const _DeleteDialog({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Item'),
      content: Text(
        'Are you sure you want to delete "${item.name}"?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
