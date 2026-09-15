class Item {
  final String name;
  final String category;
  final double currentQuantity;
  final double requiredQuantity;
  final String unit;

  final int peopleCount;
  final double quantityPerPerson;
  final int timesPerDay;

  final String lastConsumptionDate;

  Item({
    required this.name,
    required this.category,
    required this.currentQuantity,
    required this.requiredQuantity,
    required this.unit,
    required this.peopleCount,
    required this.quantityPerPerson,
    required this.timesPerDay,
    required this.lastConsumptionDate,
  });

  double get dailyConsumption {
    return peopleCount *
        quantityPerPerson *
        timesPerDay;
  }

  bool get isLowStock {
    return currentQuantity <= requiredQuantity;
  }

  double get estimatedDaysRemaining {
    if (dailyConsumption <= 0) {
      return double.infinity;
    }

    return currentQuantity / dailyConsumption;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'currentQuantity': currentQuantity,
      'requiredQuantity': requiredQuantity,
      'unit': unit,
      'peopleCount': peopleCount,
      'quantityPerPerson': quantityPerPerson,
      'timesPerDay': timesPerDay,
      'lastConsumptionDate':
          lastConsumptionDate,
    };
  }

  factory Item.fromMap(
    Map<String, dynamic> map,
  ) {
    return Item(
      name: map['name']?.toString() ?? '',
      category:
          map['category']?.toString() ?? 'Other',

      currentQuantity:
          (map['currentQuantity'] as num?)
                  ?.toDouble() ??
              0.0,

      requiredQuantity:
          (map['requiredQuantity'] as num?)
                  ?.toDouble() ??
              0.0,

      unit:
          map['unit']?.toString() ?? 'g',

      peopleCount:
          (map['peopleCount'] as num?)
                  ?.toInt() ??
              1,

      quantityPerPerson:
          (map['quantityPerPerson'] as num?)
                  ?.toDouble() ??
              0.0,

      timesPerDay:
          (map['timesPerDay'] as num?)
                  ?.toInt() ??
              1,

      lastConsumptionDate:
          map['lastConsumptionDate']
                  ?.toString() ??
              dateOnly(DateTime.now()),
    );
  }

  static String dateOnly(
    DateTime date,
  ) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}