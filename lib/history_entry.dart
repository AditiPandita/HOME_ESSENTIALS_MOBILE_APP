class HistoryEntry {
  final String action;
  final String itemName;

  final double? oldQuantity;
  final String? oldUnit;

  final double? newQuantity;
  final String? newUnit;

  final int? peopleCount;

  final DateTime dateTime;

  const HistoryEntry({
    required this.action,
    required this.itemName,
    this.oldQuantity,
    this.oldUnit,
    this.newQuantity,
    this.newUnit,
    this.peopleCount,
    required this.dateTime,
  });
}