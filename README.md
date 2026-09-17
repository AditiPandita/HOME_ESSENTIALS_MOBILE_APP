# Home Essentials

A Flutter-based mobile application designed to simplify household inventory tracking and grocery management[cite: 1]. The app provides a centralized interface for monitoring stock levels, automatically identifying low-stock items, managing a dedicated grocery list, and maintaining historical records of all inventory operations[cite: 1].

---

## 📌 Table of Contents
- [Project Overview](#-project-overview)
- [Key Features](#-key-features)
- [Application Workflow](#-application-workflow)
- [Screens](#-screens)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Data Models & Logic](#-data-models--logic)
- [Getting Started](#-getting-started)
- [Development Commands](#-development-commands)
- [Roadmap & Limitations](#-roadmap--limitations)
- [Troubleshooting](#-troubleshooting)

---

## 📖 Project Overview

Managing household groceries manually makes it easy to lose track of what is running low, available quantities, and intended purchases[cite: 1]. **Home Essentials** addresses this by evaluating current stock against required levels, allowing manual and automated list additions, and enabling seamless restocking[cite: 1].

### Objectives
- Maintain a digital household inventory with current and required quantities[cite: 1].
- Automatically identify items that fall below required stock thresholds[cite: 1].
- Separate the general inventory from an active **Grocery List**[cite: 1].
- Provide single-item and bulk (`Restock All`) restocking workflows that preserve item records[cite: 1].
- Maintain a chronological activity history for full visibility[cite: 1].
- Support unit conversion/normalization across compatible measurements (e.g., kg/g, litres/ml)[cite: 1].

---

## ✨ Key Features

| Feature | Description |
| :--- | :--- |
| **Inventory Management** | Add, edit, and delete items with name, current quantity/unit, and required quantity/unit[cite: 1]. |
| **Low Stock Detection** | Automatically flags items where `Current Quantity < Required Quantity`[cite: 1]. |
| **Separate Grocery List** | Manage shopping needs independently from automatic low-stock lists[cite: 1]. |
| **Quick Add (`+`)** | Quickly transfer any inventory item to the Grocery List[cite: 1]. |
| **Restock Workflow** | Restocking updates inventory to required levels, logs a history record, and removes the item from the Grocery List without deleting the item[cite: 1]. |
| **Restock All** | Batch-restock all applicable items directly from the Home screen[cite: 1]. |
| **Search** | Real-time name-based search across the inventory[cite: 1]. |
| **History Logging** | Tracks chronological events: `Item Added`, `Item Updated`, and `Item Restocked`[cite: 1]. |
| **Unit Compatibility** | Supports weight (`kg`, `g`), volume (`litres`, `ml`), and count (`pieces`, `packets`)[cite: 1]. |
| **User Feedback** | Non-blocking `SnackBar` notifications and confirmation dialogs for key actions[cite: 1]. |

---

## 🔄 Application Workflow
->
                    ADD ITEM
                       │
                       ▼
                   INVENTORY
                       │
                       ▼
             Compare Current Quantity
              with Required Quantity
                       │
              ┌────────┴────────┐
              │                 │
          Current <         Current >=
          Required          Required
              │                 │
              ▼                 ▼
          LOW STOCK        Normal Stock
              │
              ▼
        GROCERY LIST
              │
              ▼
           RESTOCK
              │
       ┌──────┴──────┐
       │             │
       ▼             ▼
Update Inventory   Remove from
                 Grocery List
       │
       ▼
Create History Entry


---

## 📱 Screens

- **Home Screen**: Features a quick-glance dashboard divided into two distinct sections: **Low Stock** (items needing attention) and **Grocery List** (items explicitly queued for purchase with selection toggles)[cite: 1]. Offers quick access to `View All` and `Restock All`[cite: 1].
- **Inventory Screen**: The master item directory[cite: 1]. Supports real-time search, adding new items, editing existing records, deletion, and quick-add (`+`) to the Grocery List[cite: 1].
- **History Screen**: Chronological, newest-first audit trail recording item creations, updates, and restocking actions alongside previous/current quantity changes[cite: 1].

---

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Material Design 3 patterns)[cite: 1]
- **Language**: [Dart](https://dart.dev/)[cite: 1]
- **Target Platform**: Android[cite: 1]
- **Storage**: In-Memory state (`List<Item>`, `List<HistoryEntry>`)[cite: 1]
- **IDE**: VS Code / Android Studio[cite: 1]

---

## 📂 Project Structure


home_essentials/
├── android/
├── ios/
├── web/
├── windows/
├── lib/
│   ├── main.dart               # Entry point, navigation, and centralized state management
│   ├── item_model.dart         # Item entity definition
│   ├── history_entry.dart      # HistoryEntry model definition
│   ├── home_screen.dart        # Home view (Low Stock & Grocery List)
│   ├── add_item_screen.dart    # Inventory directory, search, & add/edit interface
│   ├── history_screen.dart     # Audit trail / activity history view
│   ├── app_theme.dart          # Colors, typography, and styling configurations
│   ├── glass_background.dart   # Reusable UI component
│   └── default_quantities.dart # Predefined baseline quantity constants
├── test/
├── pubspec.yaml
└── README.md

## 🧠 Data Models & Logic

### Item Model (`item_model.dart`)
- `name`: Name of the household item[cite: 1].
- `currentQuantity` / `currentUnit`: Available quantity and measurement unit[cite: 1].
- `requiredQuantity` / `requiredUnit`: Target baseline quantity and unit[cite: 1].
- `previousQuantity` / `previousUnit`: Pre-modification quantities for audit tracking[cite: 1].
- `peopleCount`: Internal consumption scaling metric (default: `2`)[cite: 1].

### Units & Stock Detection
Units are compared using internal normalization without modifying original display values:
- `1 kg = 1000 g`[cite: 1]
- `1 litre = 1000 ml`[cite: 1]
- Rule: If `Current Quantity < Required Quantity`, flag as **Low Stock**[cite: 1].

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and configured in system `PATH`[cite: 1]
- [Android Studio](https://developer.android.com/studio) & Android SDK[cite: 1]
- VS Code (with Flutter & Dart extensions)[cite: 1]

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd home_essentials
   ```[cite: 1]

2. **Verify installation:**
   ```bash
   flutter doctor
   ```[cite: 1]

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```[cite: 1]

4. **Launch the application:**
   ```bash
   flutter devices
   flutter run
   ```[cite: 1]

---

## 💻 Development Commands

| Command | Action |
| :--- | :--- |
| `flutter pub get` | Fetch package dependencies[cite: 1] |
| `flutter analyze` | Run static Dart analysis[cite: 1] |
| `dart format lib` | Auto-format Dart source files[cite: 1] |
| `flutter test` | Run local unit and widget test suites[cite: 1] |
| `flutter build apk --release` | Generate production Android release APK[cite: 1] |
| `flutter clean` | Clear cached builds and dependencies[cite: 1] |

---

## 🗺 Roadmap & Limitations

### Current Limitations
- **In-Memory Storage**: Inventory, grocery lists, and history reset on app restarts[cite: 1].
- **No Cloud/Auth**: Single-device usage without cloud sync or user accounts[cite: 1].

### Development Phases
- [x] **Phase 1 (Core)**: Inventory CRUD, Low Stock detection, Grocery List, Restock, and History[cite: 1].
- [x] **Phase 2 (UX Enhancements)**: Multi-unit normalization, search, batch restocking, and item images[cite: 1].
- [ ] **Phase 3 (Persistence)**: Local persistence via SQLite, Hive, or shared storage[cite: 1].
- [ ] **Phase 4 (Smart Services)**: Scheduled push notifications and consumption analytics[cite: 1].
- [ ] **Phase 5 (Cloud & Multi-user)**: Cloud synchronization, authentication, and family sharing[cite: 1].
- [ ] **Phase 6 (Advanced)**: Barcode/QR scanning, voice actions, and smart AI replenishment predictions[cite: 1].

---

## 🔧 Troubleshooting

- **Flutter commands not recognized:** Check system environment variables to confirm the Flutter SDK `/bin` directory is added to your system `PATH`[cite: 1]. Run `flutter doctor`[cite: 1].
- **Device not found:** Run `flutter devices` and verify USB debugging (for physical devices) or verify the Android emulator is running[cite: 1].
- **Build cache issues:**
  ```bash
  flutter clean
  flutter pub get
  flutter run
  ```[cite: 1]
