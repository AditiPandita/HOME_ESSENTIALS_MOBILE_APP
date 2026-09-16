class Item {
  String name;

  // Previous recorded quantity
  double? previousQuantity;
  String? previousUnit;

  // Current quantity
  double currentQuantity;
  String currentUnit;

  // Required quantity
  double requiredQuantity;
  String requiredUnit;

  // Kept internally as 2 as requested
  int peopleCount;

  String lastConsumptionDate;

  Item({
    required String name,
    this.previousQuantity,
    this.previousUnit,
    required this.currentQuantity,
    required this.currentUnit,
    required this.requiredQuantity,
    required this.requiredUnit,
    required this.peopleCount,
    required this.lastConsumptionDate,
  }) : name = capitalizeFirstLetter(name);

  // ============================================================
  // CAPITALIZE ITEM NAME
  // ============================================================

  static String capitalizeFirstLetter(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return trimmed;
    }

    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }

  // ============================================================
  // CONVERT QUANTITY TO BASE UNIT
  // ============================================================

  static double quantityInBaseUnit(
    double quantity,
    String unit,
  ) {
    switch (unit.toLowerCase()) {
      case 'kg':
        return quantity * 1000;

      case 'g':
        return quantity;

      case 'litres':
      case 'litre':
      case 'liter':
      case 'liters':
      case 'l':
        return quantity * 1000;

      case 'ml':
        return quantity;

      case 'pieces':
      case 'piece':
      case 'packets':
      case 'packet':
        return quantity;

      default:
        return quantity;
    }
  }

  // ============================================================
  // LOW STOCK
  // ============================================================

  bool isLowStockAgainst(
    double effectiveRequiredQuantity,
    String effectiveRequiredUnit,
  ) {
    final currentBase = quantityInBaseUnit(
      currentQuantity,
      currentUnit,
    );

    final requiredBase = quantityInBaseUnit(
      effectiveRequiredQuantity,
      effectiveRequiredUnit,
    );

    return currentBase < requiredBase;
  }

  // Existing compatibility getter.
  //
  // This uses the item's stored required quantity.
  // MainScreen will use isLowStockAgainst() when
  // history-based required quantities are available.
  bool get isLowStock {
    final currentBase = quantityInBaseUnit(
      currentQuantity,
      currentUnit,
    );

    final requiredBase = quantityInBaseUnit(
      requiredQuantity,
      requiredUnit,
    );

    return currentBase < requiredBase;
  }

  // ============================================================
  // DATE
  // ============================================================

  static String dateOnly(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'name': name,

      'previousQuantity': previousQuantity,
      'previousUnit': previousUnit,

      'currentQuantity': currentQuantity,
      'currentUnit': currentUnit,

      'requiredQuantity': requiredQuantity,
      'requiredUnit': requiredUnit,

      'peopleCount': 2,
      'lastConsumptionDate': lastConsumptionDate,
    };
  }

  // ============================================================
  // FROM MAP
  // ============================================================

  factory Item.fromMap(
    Map<String, dynamic> map,
  ) {
    return Item(
      name: map['name']?.toString() ?? '',

      previousQuantity:
          map['previousQuantity'] == null
              ? null
              : (map['previousQuantity'] as num)
                  .toDouble(),

      previousUnit:
          map['previousUnit']?.toString(),

      currentQuantity:
          (map['currentQuantity'] as num)
              .toDouble(),

      currentUnit:
          map['currentUnit']?.toString() ?? 'kg',

      requiredQuantity:
          (map['requiredQuantity'] as num)
              .toDouble(),

      requiredUnit:
          map['requiredUnit']?.toString() ?? 'kg',

      peopleCount: 2,

      lastConsumptionDate:
          map['lastConsumptionDate']
                  ?.toString() ??
              dateOnly(DateTime.now()),
    );
  }
}