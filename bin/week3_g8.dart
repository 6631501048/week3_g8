import 'package:week3_g8/week3_g8.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'dart:convert';
//============================================================


//================= Fea 1+2 =================
void main() async {
  int key = 1;
  while (key == 1) {
    print("--Account--");
    print("1. Login");
    print("2. Registration");
    stdout.write("Choose the number: ");
    String? service = stdin.readLineSync();
    if (service == '1') {
      await login();
      key = 0;
    } else if (service == '2') {
      await register();
    } else {
      print("please select the number");
    }
  }
  print("---------- Bye ----------");
}

Future<void> register() async {
  print("==== Registration ====");
  stdout.write("Username: ");
  String? username = stdin.readLineSync()?.trim();
  stdout.write("Password: ");
  String? password = stdin.readLineSync()?.trim();
  if (username == null || password == null) {
    print("Incomplete input");
    return;
  }
  final body = {"username": username, "password": password};
  final url = Uri.parse('http://localhost:3000/register');
  final response = await http.post(url, body: body);
  if (response.statusCode == 200) {
    final result = response.body;
    print(result);
  } else if (response.statusCode == 401 || response.statusCode == 500) {
    final result = response.body;
    print(result);
  } else {
    print("Unknown error");
  }
}

Future<void> login() async {
  print("===== Login =====");
  // Get username and password
  stdout.write("Username: ");
  String? username = stdin.readLineSync()?.trim();
  stdout.write("Password: ");
  String? password = stdin.readLineSync()?.trim();
  if (username == null || password == null) {
    print("Incomplete input");
    return;
  }
  final body = {"username": username, "password": password};
  final url = Uri.parse('http://localhost:3000/login');
  final response = await http.post(url, body: body);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final userId = data['userId'];
    print("Login OK!");
    await showmenu(userId);
  } else if (response.statusCode == 401 || response.statusCode == 500) {
    final result = response.body;
    print(result);
  } else {
    print("Unknown error");
  }
}

Future<void> showmenu(int userId) async {
  String? choice;
  do {
    print("======= Expense tracking app =======");
    print("1.all expenses");
    print("2.Today's expenses");
    print("3.Search expenses");
    print("4.Add new expense");
    print("5.Delete an expense");
    print("6. Exit");
    stdout.write("Choose... ");
    choice = stdin.readLineSync();
    if (choice == "1") {
      await showAllExpenses(userId);
    } else if (choice == "2") {
      await showTodayExpenses(userId);
    } else if (choice == "3") {
      await searchExpenses(userId);
      }else if (choice == "4"){
      await addExpense(userId);
      }else if (choice == "5") {
      await deleteExpense(userId);
    } else if (choice != "6") {
      print("Invalid choice");
    }
  } while (choice != "6");
}

Future<void> showAllExpenses(int userId) async {
  final url = Uri.parse('http://localhost:3000/expenses/$userId');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final List expenses = jsonDecode(response.body);
    if (expenses.isEmpty) {
      print("Notthing bruhh");
    } else {
      int total = 0;
      print("------------ All Expenses ------------");
      for (var exp in expenses) {
        print(
          " ${exp['id']}. ${exp['items']} : ${exp['paid']}฿ :${exp['date']}",
        );
        total += (exp['paid'] as num).toInt();
      }
      print("Total expense: ${total}฿ ");
    }
  } else {
    print("Error fetching expenses: ${response.body}");
  }
}

Future<void> showTodayExpenses(int userId) async {
  final url = Uri.parse('http://localhost:3000/expenses/today/$userId');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final List expenses = jsonDecode(response.body);
    if (expenses.isEmpty) {
      print("Notthing for today");
    } else {
      print("------------ Today's Expenses ------------");
      int total = 0;
      for (var exp in expenses) {
        print(
          " ${exp['id']}. ${exp['items']} : ${exp['paid']}฿ :${exp['date']}",
        );
        total += (exp['paid'] as num).toInt();
      }
      print("Total expenses: ${total}฿ ");
    }
  } else {
    print("Error fetching today's expenses: ${response.body}");
  }
}

//================= Fea 3 =================

Future<void> searchExpenses(int userId) async {
  stdout.write("Item to search: ");
  String? keyword = stdin.readLineSync()?.trim();
  if (keyword == null || keyword.isEmpty) {
    print("No keyword entered.");
    return;
  }
  final url = Uri.parse('http://localhost:3000/expenses/search/$userId?keyword=$keyword');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final List expenses = jsonDecode(response.body);
    if (expenses.isEmpty) {
      print("No item '$keyword'.");
    } else {
      print("------ Search Results ------");
      for (var exp in expenses) {
        print(" ${exp['id']}. ${exp['items']} : ${exp['paid']}฿ :${exp['date']}");
      }
    }
  } else {
    print("Error searching expenses: ${response.body}");
  }
}

//================= Fea 4 =================
Future<void> addExpense(int userId) async {
  stdout.write("Item: ");
  String? item = stdin.readLineSync()?.trim();
  stdout.write("Paid amount: ");
  String? paidStr = stdin.readLineSync()?.trim();
  int? paid = int.tryParse(paidStr ?? "");

  if (item == null || item.isEmpty || paid == null) {
    print("Invalid input.");
    return;
  }

  final body = {"items": item, "paid": paid.toString(), "userId": userId.toString()};
  final url = Uri.parse('http://localhost:3000/expenses/add');
  final response = await http.post(url, body: body);

  if (response.statusCode == 200) {
    print("Expense added successfully!");
  } else {
    print("Error: ${response.body}");
  }
}
//================= Fea 5 =================
Future<void> deleteExpense(int userId) async {
  print("==== Delete Expense ====");
  stdout.write("Enter Expense ID to delete: ");
  String? idInput = stdin.readLineSync();
  if (idInput == null || idInput.isEmpty) {
    print("Invalid ID.");
    return;
  }

  final url = Uri.parse('http://localhost:3000/expenses/$userId/$idInput');
  final response = await http.delete(url);

  if (response.statusCode == 200) {
    print("✅ Expense deleted successfully.");
  } else if (response.statusCode == 404) {
    print("⚠️ Expense not found.");
  } else {
    print("❌ Error deleting expense: ${response.body}");
  }
}

//================= Fea 6 =================
void exitApp() {
  print("---------- Bye -----------");
  exit(0);
}	