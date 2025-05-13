import 'package:hive_flutter/hive_flutter.dart';
import 'package:managment/data/model/add_date.dart'; // Ensure this path is correct

// Access the Hive box (make sure it's opened in main.dart)
final box = Hive.box<Add_data>('data');

int calculateTimeValue(List<Add_data> dataList, bool isToday, int index) {
  // Use int.tryParse to handle potential parsing errors
  int? parsedAmount = int.tryParse(dataList[index].amount);

  // If parsing fails (amount is not a valid integer), return 0 or handle the error as needed.
  int timeValue = parsedAmount ?? 0; // Use 0 as a default value

  return timeValue;
}
double total() {
  var history = box.values.toList();
  double totalAmount = 0.0;

  for (var item in history) {
    // Use double.tryParse for safe conversion from String to double
    double? amount = double.tryParse(item.amount);

    if (amount != null) { // Proceed only if parsing was successful
      if (item.IN == 'Income') {
        totalAmount += amount;
      } else if (item.IN == 'Expand') { // Assuming 'Expand' means expense
        totalAmount -= amount;
      }
    } else {
      // Optional: Log or handle cases where amount is not a valid number
      print("Warning: Could not parse amount '${item.amount}' for item '${item.name}'. Skipping in total calculation.");
    }
  }
  return totalAmount;
}


double income() {
  var history = box.values.toList();
  double incomeAmount = 0.0;

  for (var item in history) {
    if (item.IN == 'Income') {
      double? amount = double.tryParse(item.amount);
      if (amount != null) {
        incomeAmount += amount;
      } else {
        print("Warning: Could not parse amount '${item.amount}' for income item '${item.name}'. Skipping.");
      }
    }
  }
  return incomeAmount;
}


double expenses() {
  var history = box.values.toList();
  double expenseAmount = 0.0;

  for (var item in history) {
    if (item.IN == 'Expand') { // Assuming 'Expand' means expense
      double? amount = double.tryParse(item.amount);
      if (amount != null) {
        expenseAmount += amount; // Summing up the expense amounts
      } else {
         print("Warning: Could not parse amount '${item.amount}' for expense item '${item.name}'. Skipping.");
      }
    }
  }
  return expenseAmount;
}

List<Add_data> today() {
  var history = box.values.toList();
  List<Add_data> todayResults = [];
  DateTime now = DateTime.now();
  DateTime todayStart = DateTime(now.year, now.month, now.day); // Start of today
   DateTime todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59); // End of today


  for (var item in history) {
    // Check if the item's date falls within today
    if (item.datetime.isAfter(todayStart.subtract(const Duration(microseconds: 1))) &&
        item.datetime.isBefore(todayEnd.add(const Duration(microseconds: 1)))) {
      todayResults.add(item);
    }
  }
   // Optional: Sort by time if needed
  todayResults.sort((a, b) => b.datetime.compareTo(a.datetime));
  return todayResults;
}

/// Filters transactions for the current week (last 7 days).
List<Add_data> week() {
  var history = box.values.toList();
  List<Add_data> weekResults = [];
  DateTime now = DateTime.now();
  DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));

  for (var item in history) {
    // Check if the item's date is within the last 7 days (inclusive of today)
    if (item.datetime.isAfter(sevenDaysAgo)) {
      weekResults.add(item);
    }
  }
   weekResults.sort((a, b) => b.datetime.compareTo(a.datetime));
  return weekResults;
}

/// Filters transactions for the current month (last 30 days approximation).
/// For exact month filtering, more complex date logic is needed.
List<Add_data> month() {
  var history = box.values.toList();
  List<Add_data> monthResults = [];
  DateTime now = DateTime.now();
   DateTime thirtyDaysAgo = now.subtract(const Duration(days: 30));
   // More accurate: Find the first day of the current month
   // DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);

  for (var item in history) {
     // Using 30 days ago for simplicity as per original structure
     if (item.datetime.isAfter(thirtyDaysAgo)) {
       monthResults.add(item);
     }
     // More accurate check:
     // if (item.datetime.year == now.year && item.datetime.month == now.month) {
     //    monthResults.add(item);
     // }
  }
   monthResults.sort((a, b) => b.datetime.compareTo(a.datetime));
  return monthResults;
}

/// Filters transactions for the current year (last 365 days approximation).
/// For exact year filtering, compare the year component.
List<Add_data> year() {
  var history = box.values.toList();
  List<Add_data> yearResults = [];
  DateTime now = DateTime.now();
  DateTime yearAgo = now.subtract(const Duration(days: 365));
  // More accurate:
  // int currentYear = now.year;

  for (var item in history) {
    // Using 365 days ago for simplicity
     if (item.datetime.isAfter(yearAgo)) {
       yearResults.add(item);
     }
    // More accurate check:
    // if (item.datetime.year == currentYear) {
    //   yearResults.add(item);
    // }
  }
  yearResults.sort((a, b) => b.datetime.compareTo(a.datetime));
  return yearResults;
}

// --- Chart Data Helper (Example - adjust based on your Chart widget needs) ---

/// Groups transactions by category name for chart display.
/// Returns a map where keys are category names and values are total amounts.
Map<String, double> groupTransactionsByCategory(List<Add_data> transactions) {
  Map<String, double> categoryTotals = {};

  for (var item in transactions) {
     double? amount = double.tryParse(item.amount);
     if (amount != null) {
       // Accumulate amounts for each category
       categoryTotals.update(
         item.name, // Assuming 'name' is the category
         (value) => value + amount,
         ifAbsent: () => amount,
       );
     }
  }
  return categoryTotals;
}