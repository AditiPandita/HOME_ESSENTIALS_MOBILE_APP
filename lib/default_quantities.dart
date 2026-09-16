class DefaultQuantity {
  final double quantity;
  final String unit;

  const DefaultQuantity({
    required this.quantity,
    required this.unit,
  });
}

// ============================================================
// DEFAULT REQUIRED QUANTITIES
//
// These are used when an item does NOT have useful history.
//
// You can change these values whenever you want.
// Each item has its own default.
// ============================================================

const Map<String, DefaultQuantity>
    defaultRequiredQuantities = {
  'rice': DefaultQuantity(
    quantity: 5,
    unit: 'kg',
  ),

  'wheat': DefaultQuantity(
    quantity: 5,
    unit: 'kg',
  ),

  'sugar': DefaultQuantity(
    quantity: 2,
    unit: 'kg',
  ),

  'salt': DefaultQuantity(
    quantity: 1,
    unit: 'kg',
  ),

  'oil': DefaultQuantity(
    quantity: 2,
    unit: 'litres',
  ),

  'milk': DefaultQuantity(
    quantity: 2,
    unit: 'litres',
  ),

  'dal': DefaultQuantity(
    quantity: 2,
    unit: 'kg',
  ),

  'tea': DefaultQuantity(
    quantity: 500,
    unit: 'g',
  ),

  'coffee': DefaultQuantity(
    quantity: 500,
    unit: 'g',
  ),
};

// ============================================================
// FALLBACK DEFAULT
//
// Used for an item that isn't listed above.
// ============================================================

const DefaultQuantity fallbackDefaultQuantity =
    DefaultQuantity(
  quantity: 1,
  unit: 'pieces',
);