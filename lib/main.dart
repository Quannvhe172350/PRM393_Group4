import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supermarket_project_prm392_group4/providers/product_provider.dart';
import 'package:supermarket_project_prm392_group4/providers/category_provider.dart';
import 'package:supermarket_project_prm392_group4/providers/order_provider.dart';
import 'package:supermarket_project_prm392_group4/providers/employee_provider.dart';
import 'package:supermarket_project_prm392_group4/providers/supplier_provider.dart';
import 'package:supermarket_project_prm392_group4/view/home_screen.dart';
import 'package:supermarket_project_prm392_group4/view/login_screen.dart';
import 'package:supermarket_project_prm392_group4/view/product_screen.dart';
import 'package:supermarket_project_prm392_group4/view/manager/manager_dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => SupplierProvider()),
      ],
      child: MaterialApp(
        title: 'Supermarket Management',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        ),

        // Màn hình đầu tiên
        initialRoute: '/',

        // Danh sách routes
        routes: {
          '/': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
          '/products': (context) => ProductScreen(),
          '/manager': (context) => const ManagerDashboardScreen(),
        },
      ),
    );
  }
}
