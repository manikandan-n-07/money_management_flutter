# 💸 Cashier — Premium Offline Expense & Split Management App

Cashier is a state-of-the-art, fully offline-first mobile application built with Flutter to manage personal finances, budget limits, and split group expenses without relying on cloud services. Focused on data privacy, premium aesthetics, micro-animations, and fluid transitions, Cashier gives you full control of your wallets locally.

---

## ✨ Key Features

### 🎨 Premium UI/UX & Fluid Transitions
*   **Super Snappy Splash Screen**: Opens with a fast `800ms` bouncing logo animation, transitioning into the main dashboard with a smooth cross-fade.
*   **Custom Sliding Navigation capsule**: Replaced standard navigation bars with a capsule dock floating above the content, featuring an `AnimatedPositioned` sliding background pill that stretches and slides dynamically as you switch tabs.
*   **Adaptive Dark & Light Themes**: Listens to system-wide theme preferences reactively. Toggling between Dark and Light mode on your device immediately updates the application style without requiring restarts.

### 📝 Comprehensive Expense Tracker
*   **Full CRUD Capabilities**: Add, edit, view, and organize expenses with custom categories, location tags, dates, and notes.
*   **Swipe Actions**: Swipe-left to trigger a warning dialog for permanent deletion (with a 10-second Undo toast), and swipe-right to immediately edit the transaction.
*   **Dynamic Categorization**: Visual selectors featuring custom colors and emojis for categorization.
*   **Time-based Filters**: Group and filter transactions by Today, Week, Month, Year, or All.

### 👥 Split Bills & Group Payments
*   **Flexible Splits**: Split bills equally or scale unequal percentages/amounts proportionally when editing total splits.
*   **Interactive Settlement**: Toggle paid/unpaid switches individually per member, with collected vs. pending bars.
*   **Double-swipe Actions**:
    *   *Swipe-Right to Edit*: Instantly invokes the edit dialog to modify description, total amount, payer, or friend names.
    *   *Swipe-Left to Delete*: Triggers an AlertDialog warning before permanently removing the split group.

### 📊 Offline Budget Safety & Spending Trends
*   **Visual Budgets**: Dynamic monthly budget progress tracker warning you visually when expenses cross limits.
*   **7-Day Trends**: Smooth Bezier spending lines visualizing weekly expenditure.

### 🔔 Local Smart Notifications (100% Offline)
*   **Daily Reminders**: Repeating daily notification scheduled at 9:00 PM local time prompting you to log outstanding logs.
*   **Budget Limit Warnings**: Alerts when monthly spending exceeds `60%` (warn threshold) or `85%` (danger limit).
*   **Smart Spent Reports**: Compares today's total spending against yesterday's and pushes a local summary message (e.g. *"Great! You spent ₹120 (30%) LESS today compared to yesterday"*).

### 📄 Document Export Utility
*   **Personalized PDF Report**: Generates professional PDF invoices containing an expense summary, history tables, and split sheets listing member names. Replaces non-Latin1 characters (such as `₹`) with safe strings (such as `Rs.`) to guarantee clean rendering without rectangular glyph errors.
*   **Multi-sheet Excel Export**: Exports sheets for Expenses, Split Expenses, and Monthly statistics.

---

## 🛠️ Technology Stack

*   **Framework**: [Flutter](https://flutter.dev/) (Impeller renderer enabled)
*   **State Management**: [Riverpod](https://riverpod.dev/) (Decoupled reactive architectures)
*   **Local Database**: [Hive](https://pub.dev/packages/hive) (High performance local binary storage)
*   **Reports & Sheets**: [pdf](https://pub.dev/packages/pdf), [excel](https://pub.dev/packages/excel)
*   **Local Reminders**: [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
*   **Preferences**: [shared_preferences](https://pub.dev/packages/shared_preferences)

---

## 🚀 Getting Started & CLI Commands

Follow these steps to clean, analyze, test, and deploy the application.

### 📦 1. Pre-requisites & Setup
Ensure you have the Flutter SDK installed on your machine.

Clone the repository and fetch the required dependencies:
```bash
# Get Flutter packages
flutter pub get
```

### 🧹 2. Code Housekeeping
Clean the build caches and run the static analyzer:
```bash
# Clean cache
flutter clean

# Get fresh package references
flutter pub get

# Run strict linter verification (Ensure: No issues found!)
flutter analyze
```

### 🧪 3. Run Verification Tests
Verify code behavior:
```bash
# Run unit & widget tests
flutter test
```

### 🚀 4. Launching the App
Ensure a mobile device or emulator is running and execute:
```bash
# Run on default emulator
flutter run

# Run in Release mode for production-grade profiling
flutter run --release
```

### 🏗️ 5. Build Distribution Bundles
To package the app for production releases:
```bash
# Build APK (Android)
flutter build apk --release

# Build AppBundle (Google Play Console)
flutter build appbundle --release
```

---
