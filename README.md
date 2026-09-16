# 🏠 Home Essentials

> A Flutter-based mobile application for managing household inventory, monitoring low-stock items, maintaining a grocery list, and tracking inventory history.

---

## 📌 Project Overview

**Home Essentials** is a mobile application developed using **Flutter and Dart** to simplify household grocery and essential-item management.

In a typical household, keeping track of groceries manually can become difficult. Users may forget which items are running low, how much quantity is currently available, how much quantity is required, or which items need to be purchased.

Home Essentials provides a centralized digital solution where users can:

- Maintain a household inventory
- Track current quantities
- Define required quantities
- Automatically identify low-stock items
- Maintain a separate grocery list
- Add items to the grocery list manually
- Restock items
- Edit and delete inventory items
- Search through a large inventory
- View previous inventory activities
- Track previous, current, and required quantities

The current version focuses on providing a simple and clean inventory-management experience using an in-memory data structure.

---

# 🎯 Problem Statement

Managing household groceries manually often results in several problems:

- Users may forget which items are running low.
- It can be difficult to remember the current quantity of an item.
- Required quantities are not always known or tracked.
- Grocery lists are often maintained separately using paper or messaging applications.
- There is no centralized history of inventory changes.
- Managing a large number of household items can become inconvenient.
- Different measurement units can make quantity comparison difficult.

The **Home Essentials** application addresses these problems by providing a single mobile platform for managing household inventory and grocery requirements.

---

# 🎯 Project Objectives

The primary objectives of the Home Essentials application are:

1. To digitally maintain household grocery inventory.
2. To track the current quantity of every item.
3. To define a required quantity for every inventory item.
4. To automatically detect low-stock items.
5. To maintain a separate Grocery List.
6. To allow users to manually add items to the Grocery List.
7. To provide an easy restocking mechanism.
8. To preserve inventory information after restocking.
9. To maintain a history of inventory activities.
10. To allow users to edit existing inventory information.
11. To provide search functionality for large inventories.
12. To support multiple quantity units.
13. To provide a simple and user-friendly mobile interface.
14. To provide a foundation for future database, cloud, notification, and AI-based features.

---

# ✨ Key Features

## 1. 📦 Inventory Management

The application allows users to maintain a list of household items.

Each inventory item contains information such as:

- Item Name
- Current Quantity
- Current Quantity Unit
- Required Quantity
- Required Quantity Unit
- Previous Quantity
- Previous Quantity Unit

Example:

```text
Rice

Previous: 5 kg
Current: 2 kg
Required: 5 kg
