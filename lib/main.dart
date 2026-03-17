import 'package:flutter/material.dart';
import 'package:supermarket_project_prm392_group4/view/home_screen.dart';
import 'package:supermarket_project_prm392_group4/view/login_screen.dart';
import 'package:supermarket_project_prm392_group4/view/product_screen.dart';
import 'package:supermarket_project_prm392_group4/view/user_list_screen.dart';
import 'package:supermarket_project_prm392_group4/view/user_detail_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supermarket Management',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(primarySwatch: Colors.green),

      // Màn hình đầu tiên
      initialRoute: '/',

      // Danh sách routes
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/products': (context) => const ProductScreen(),
        '/users': (context) => const UserListScreen(),
        '/userDetail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is int) {
            return UserDetailScreen(userId: args);
          }
          return const Scaffold(
            body: Center(child: Text('Thiếu tham số userId')),
          );
        },
      },
    );
  }
}

