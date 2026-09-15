import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_item_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with WidgetsBindingObserver {
  int selectedIndex = 0;

  List<Item> items = [];
  List<String> history = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      applyAutomaticConsumption();
    }
  }

  Future<void> loadData() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      final savedItems =
          prefs.getStringList('items') ?? [];

      final savedHistory =
          prefs.getStringList('history') ?? [];

      final loadedItems = <Item>[];

      for (final savedItem in savedItems) {
        try {
          final decoded = jsonDecode(savedItem);

          if (decoded is Map) {
            loadedItems.add(
              Item.fromMap(
                Map<String, dynamic>.from(decoded),
              ),
            );
          }
        } catch (_) {}
      }

      if (!mounted) return;

      setState(() {
        items = loadedItems;
        history = savedHistory;
        isLoading = false;
      });

      await applyAutomaticConsumption();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        items = [];
        history = [];
        isLoading = false;
      });
    }
  }

  Future<void> applyAutomaticConsumption() async {
    if (items.isEmpty) return;

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final todayString = Item.dateOnly(today);

    bool changed = false;

    final updatedItems = <Item>[];
    final newHistory = <String>[];

    for (final item in items) {
      final lastDate = DateTime.tryParse(
        item.lastConsumptionDate,
      );

      if (lastDate == null) {
        updatedItems.add(
          Item(
            name: item.name,
            category: item.category,
            currentQuantity: item.currentQuantity,
            requiredQuantity: item.requiredQuantity,
            unit: item.unit,
            peopleCount: item.peopleCount,
            quantityPerPerson: item.quantityPerPerson,
            timesPerDay: item.timesPerDay,
            lastConsumptionDate: todayString,
          ),
        );

        changed = true;
        continue;
      }

      final lastDay = DateTime(
        lastDate.year,
        lastDate.month,
        lastDate.day,
      );

      final daysPassed =
          today.difference(lastDay).inDays;

      if (daysPassed <= 0) {
        updatedItems.add(item);
        continue;
      }

      final dailyConsumption =
          item.dailyConsumption;

      if (dailyConsumption <= 0) {
        updatedItems.add(
          Item(
            name: item.name,
            category: item.category,
            currentQuantity: item.currentQuantity,
            requiredQuantity: item.requiredQuantity,
            unit: item.unit,
            peopleCount: item.peopleCount,
            quantityPerPerson: item.quantityPerPerson,
            timesPerDay: item.timesPerDay,
            lastConsumptionDate: todayString,
          ),
        );

        changed = true;
        continue;
      }

      final consumed =
          dailyConsumption * daysPassed;

      double newQuantity =
          item.currentQuantity - consumed;

      if (newQuantity < 0) {
        newQuantity = 0;
      }

      updatedItems.add(
        Item(
          name: item.name,
          category: item.category,
          currentQuantity: newQuantity,
          requiredQuantity: item.requiredQuantity,
          unit: item.unit,
          peopleCount: item.peopleCount,
          quantityPerPerson: item.quantityPerPerson,
          timesPerDay: item.timesPerDay,
          lastConsumptionDate: todayString,
        ),
      );

      newHistory.add(
        '${item.name}: '
        '${consumed.toStringAsFixed(2)} '
        '${item.unit} automatically consumed '
        'over $daysPassed day(s)',
      );

      changed = true;
    }

    if (!changed || !mounted) return;

    setState(() {
      items = updatedItems;
      history.addAll(newHistory);
    });

    await saveData();
  }

  Future<void> saveData() async {
    final prefs =
        await SharedPreferences.getInstance();

    final encodedItems = items.map((item) {
      return jsonEncode(item.toMap());
    }).toList();

    await prefs.setStringList(
      'items',
      encodedItems,
    );

    await prefs.setStringList(
      'history',
      history,
    );
  }

  Future<void> addItem(Item item) async {
    final index = items.indexWhere(
      (existingItem) =>
          existingItem.name.trim().toLowerCase() ==
          item.name.trim().toLowerCase(),
    );

    if (!mounted) return;

    if (index == -1) {
      setState(() {
        items.add(item);

        history.add(
          '${item.name} added '
          '(${item.currentQuantity} ${item.unit})',
        );

        selectedIndex = 0;
      });
    } else {
      final oldItem = items[index];

      final updatedItem = Item(
        name: oldItem.name,
        category: item.category,
        currentQuantity:
            oldItem.currentQuantity +
            item.currentQuantity,
        requiredQuantity: item.requiredQuantity,
        unit: item.unit,
        peopleCount: item.peopleCount,
        quantityPerPerson: item.quantityPerPerson,
        timesPerDay: item.timesPerDay,
        lastConsumptionDate:
            Item.dateOnly(DateTime.now()),
      );

      setState(() {
        items[index] = updatedItem;

        history.add(
          '${item.name} restocked by '
          '${item.currentQuantity} ${item.unit}',
        );

        selectedIndex = 0;
      });
    }

    await saveData();
  }

  Future<void> restockItem(
    Item item,
    double quantity,
  ) async {
    if (quantity <= 0) return;

    final index = items.indexWhere(
      (existingItem) =>
          existingItem.name.trim().toLowerCase() ==
          item.name.trim().toLowerCase(),
    );

    if (index == -1 || !mounted) return;

    final oldItem = items[index];

    final updatedItem = Item(
      name: oldItem.name,
      category: oldItem.category,
      currentQuantity:
          oldItem.currentQuantity + quantity,
      requiredQuantity: oldItem.requiredQuantity,
      unit: oldItem.unit,
      peopleCount: oldItem.peopleCount,
      quantityPerPerson: oldItem.quantityPerPerson,
      timesPerDay: oldItem.timesPerDay,
      lastConsumptionDate:
          oldItem.lastConsumptionDate,
    );

    setState(() {
      items[index] = updatedItem;

      history.add(
        '${oldItem.name} restocked by '
        '$quantity ${oldItem.unit}',
      );
    });

    await saveData();
  }

  Future<void> editItem(
    Item oldItem,
    Item updatedItem,
  ) async {
    final index = items.indexWhere(
      (existingItem) =>
          existingItem.name.trim().toLowerCase() ==
          oldItem.name.trim().toLowerCase(),
    );

    if (index == -1 || !mounted) return;

    setState(() {
      items[index] = updatedItem;

      history.add(
        '${oldItem.name} details updated',
      );
    });

    await saveData();
  }

  Future<void> deleteItem(Item item) async {
    final index = items.indexWhere(
      (existingItem) =>
          existingItem.name.trim().toLowerCase() ==
          item.name.trim().toLowerCase(),
    );

    if (index == -1 || !mounted) return;

    setState(() {
      items.removeAt(index);

      history.add(
        '${item.name} deleted from inventory',
      );
    });

    await saveData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: [
          HomeScreen(
            items: items,
          ),

          AddItemPage(
            items: items,
            onItemAdded: addItem,
            onItemRestocked: restockItem,
            onItemEdited: editItem,
            onItemDeleted: deleteItem,
          ),

          HistoryScreen(
            history: history,
          ),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Add Items',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}