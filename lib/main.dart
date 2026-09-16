import 'package:flutter/material.dart';

import 'add_item_screen.dart' as inventory_screen;
import 'default_quantities.dart';
import 'history_entry.dart';
import 'history_screen.dart' as history_screen;
import 'home_screen.dart' as home_screen;
import 'item_model.dart';

void main() {
  runApp(const HomeEssentialsApp());
}

class HomeEssentialsApp extends StatelessWidget {
  const HomeEssentialsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home Essentials',

      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor: const Color(0xFFF8F8F1),

        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F8F5B)),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F8F1),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF315A39),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),

        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Color(0xFFF8F8F1),

          indicatorColor: Color(0xFFE7F1DF),

          elevation: 0,

          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE0E6DC)),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE0E6DC)),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF4F8F5B), width: 1.5),
          ),
        ),
      ),

      home: const MainScreen(),
    );
  }
}

// ============================================================
// MAIN SCREEN
// ============================================================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  // ============================================================
  // DATA
  // ============================================================

  // Complete inventory.
  final List<Item> items = [];

  // ONLY manually selected grocery-list items.
  final List<Item> groceryListItems = [];

  // Complete history.
  final List<HistoryEntry> history = [];

  // ============================================================
  // STARTUP
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      items.clear();
      groceryListItems.clear();
      history.clear();
    });
  }

  // ============================================================
  // FIND ITEM
  // ============================================================

  int _findItemIndex(Item item) {
    return items.indexWhere(
      (existing) =>
          existing.name.trim().toLowerCase() == item.name.trim().toLowerCase(),
    );
  }

  // ============================================================
  // EFFECTIVE REQUIRED QUANTITY
  // ============================================================
  //
  // Priority:
  //
  // 1. History of the item
  // 2. Code-defined default
  //
  // For history, the latest meaningful recorded
  // quantity is used as the historical requirement.
  //
  // This can later be changed to average / most
  // frequent purchase quantity if required.
  // ============================================================

  DefaultQuantity getEffectiveRequiredQuantity(Item item) {
    final itemHistory = history
        .where(
          (entry) =>
              entry.itemName.trim().toLowerCase() ==
              item.name.trim().toLowerCase(),
        )
        .where((entry) => entry.newQuantity != null && entry.newUnit != null)
        .toList();

    if (itemHistory.isNotEmpty) {
      itemHistory.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      final latest = itemHistory.first;

      return DefaultQuantity(
        quantity: latest.newQuantity!,
        unit: latest.newUnit!,
      );
    }

    final defaultValue =
        defaultRequiredQuantities[item.name.trim().toLowerCase()];

    return defaultValue ?? fallbackDefaultQuantity;
  }

  // ============================================================
  // LOW STOCK
  // ============================================================

  List<Item> get lowStockItems {
    return items.where((item) {
      final required = getEffectiveRequiredQuantity(item);

      return item.isLowStockAgainst(required.quantity, required.unit);
    }).toList();
  }

  // ============================================================
  // HISTORY
  // ============================================================

  void _addHistory({
    required String action,
    required String itemName,
    double? oldQuantity,
    String? oldUnit,
    double? newQuantity,
    String? newUnit,
  }) {
    history.add(
      HistoryEntry(
        action: action,
        itemName: itemName,
        oldQuantity: oldQuantity,
        oldUnit: oldUnit,
        newQuantity: newQuantity,
        newUnit: newUnit,
        peopleCount: null,
        dateTime: DateTime.now(),
      ),
    );
  }

  // ============================================================
  // ADD ITEM
  // ============================================================

  Future<void> addItem(Item item) async {
    final exists = items.any(
      (existing) =>
          existing.name.trim().toLowerCase() == item.name.trim().toLowerCase(),
    );

    if (exists) {
      return;
    }

    // Use the code-defined default required quantity
    // when one exists for this item.
    final defaultValue =
        defaultRequiredQuantities[item.name.trim().toLowerCase()];

    if (defaultValue != null) {
      item.requiredQuantity = defaultValue.quantity;
      item.requiredUnit = defaultValue.unit;
    }

    setState(() {
      // ----------------------------------------------------------
      // 1. ADD TO INVENTORY
      // ----------------------------------------------------------
      items.add(item);

      // ----------------------------------------------------------
      // 2. AUTOMATICALLY ADD TO GROCERY LIST
      // ----------------------------------------------------------
      final alreadyInGroceryList = groceryListItems.any(
        (existing) =>
            existing.name.trim().toLowerCase() ==
            item.name.trim().toLowerCase(),
      );

      if (!alreadyInGroceryList) {
        groceryListItems.add(item);
      }

      // ----------------------------------------------------------
      // 3. ADD HISTORY
      // ----------------------------------------------------------
      _addHistory(
        action: 'Item Added',
        itemName: item.name,
        newQuantity: item.currentQuantity,
        newUnit: item.currentUnit,
      );
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${item.name} added'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
          duration: const Duration(seconds: 2),
        ),
      );
  }
  // ============================================================
  // ADD TO GROCERY LIST
  // ============================================================

  Future<void> addToGroceryList(Item item) async {
    final alreadyAdded = groceryListItems.any(
      (existing) =>
          existing.name.trim().toLowerCase() == item.name.trim().toLowerCase(),
    );

    if (alreadyAdded) {
      return;
    }

    setState(() {
      groceryListItems.add(item);
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${item.name} added to Grocery List'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // ============================================================
  // UPDATE ITEM
  // ============================================================

  Future<void> updateItem(
    Item oldItem, {
    required String name,
    required double currentQuantity,
    required String currentUnit,
    required double requiredQuantity,
    required String requiredUnit,
    required int peopleCount,
  }) async {
    final index = _findItemIndex(oldItem);

    if (index == -1) {
      return;
    }

    final actualItem = items[index];

    final oldName = actualItem.name;
    final oldQuantity = actualItem.currentQuantity;
    final oldUnit = actualItem.currentUnit;

    final updatedItem = Item(
      name: name,
      previousQuantity: oldQuantity,
      previousUnit: oldUnit,
      currentQuantity: currentQuantity,
      currentUnit: currentUnit,
      requiredQuantity: requiredQuantity,
      requiredUnit: requiredUnit,
      peopleCount: 2,
      lastConsumptionDate: Item.dateOnly(DateTime.now()),
    );

    setState(() {
      items[index] = updatedItem;

      // Preserve Grocery List membership
      // if the item was already there.
      final wasInGroceryList = groceryListItems.any(
        (existing) =>
            existing.name.trim().toLowerCase() == oldName.trim().toLowerCase(),
      );

      groceryListItems.removeWhere(
        (existing) =>
            existing.name.trim().toLowerCase() == oldName.trim().toLowerCase(),
      );

      if (wasInGroceryList) {
        groceryListItems.add(updatedItem);
      }

      _addHistory(
        action: 'Item Updated',
        itemName: updatedItem.name,
        oldQuantity: oldQuantity,
        oldUnit: oldUnit,
        newQuantity: updatedItem.currentQuantity,
        newUnit: updatedItem.currentUnit,
      );
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${updatedItem.name} updated'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // ============================================================
  // RESTOCK
  // ============================================================

  Future<void> restockItem(Item item) async {
    final index = _findItemIndex(item);

    if (index == -1) {
      return;
    }

    final actualItem = items[index];

    final oldQuantity = actualItem.currentQuantity;
    final oldUnit = actualItem.currentUnit;

    final required = getEffectiveRequiredQuantity(actualItem);

    setState(() {
      // ----------------------------------------------------------
      // INVENTORY ITEM IS PRESERVED
      // ----------------------------------------------------------

      // Previous = quantity before restocking
      actualItem.previousQuantity = oldQuantity;
      actualItem.previousUnit = oldUnit;

      // Update quantity of the SAME item
      actualItem.currentQuantity = required.quantity;
      actualItem.currentUnit = required.unit;

      // Keep required quantity synchronized
      actualItem.requiredQuantity = required.quantity;
      actualItem.requiredUnit = required.unit;

      // ----------------------------------------------------------
      // REMOVE ONLY FROM GROCERY LIST
      // ----------------------------------------------------------

      groceryListItems.removeWhere(
        (groceryItem) =>
            groceryItem.name.trim().toLowerCase() ==
            actualItem.name.trim().toLowerCase(),
      );

      // ----------------------------------------------------------
      // HISTORY
      // ----------------------------------------------------------

      _addHistory(
        action: 'Item Restocked',
        itemName: actualItem.name,
        oldQuantity: oldQuantity,
        oldUnit: oldUnit,
        newQuantity: actualItem.currentQuantity,
        newUnit: actualItem.currentUnit,
      );
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Item restocked',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(16, 0, 16, 90),
          duration: Duration(seconds: 2),
        ),
      );
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteItem(Item item) async {
    final index = _findItemIndex(item);

    if (index == -1) {
      return;
    }

    final actualItem = items[index];

    setState(() {
      items.removeAt(index);

      groceryListItems.removeWhere(
        (groceryItem) =>
            groceryItem.name.trim().toLowerCase() ==
            actualItem.name.trim().toLowerCase(),
      );

      _addHistory(
        action: 'Item Deleted',
        itemName: actualItem.name,
        oldQuantity: actualItem.currentQuantity,
        oldUnit: actualItem.currentUnit,
      );
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,

        children: [
          home_screen.HomeScreen(
            lowStockItems: lowStockItems,

            groceryListItems: groceryListItems,

            onRestock: restockItem,

            onUpdateItem: updateItem,
          ),

          inventory_screen.AddItemScreen(
            items: items,

            onItemAdded: addItem,

            onAddToHome: addToGroceryList,

            onItemEdited: updateItem,

            onItemDeleted: deleteItem,
          ),

          history_screen.HistoryScreen(history: history),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,

        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 21),
            selectedIcon: Icon(Icons.home, size: 21),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined, size: 21),
            selectedIcon: Icon(Icons.inventory_2, size: 21),
            label: 'Inventory',
          ),

          NavigationDestination(
            icon: Icon(Icons.history_outlined, size: 21),
            selectedIcon: Icon(Icons.history, size: 21),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
