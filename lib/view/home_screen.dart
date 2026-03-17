import 'package:flutter/material.dart';
import 'product_screen.dart';
import 'user_list_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Supermarket Dashboard"),
        backgroundColor: Colors.green,
      ),

      body: Padding(
        padding: EdgeInsets.all(20),

        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,

          children: [
            buildMenu(
              context,
              "Products",
              Icons.shopping_cart,
              Colors.orange,
              ProductScreen(),
            ),

            buildMenu(
              context,
              "Users",
              Icons.person,
              Colors.teal,
              const UserListScreen(),
            ),

            buildMenu(
              context,
              "Orders",
              Icons.receipt,
              Colors.blue,
              Container(),
            ),

            buildMenu(
              context,
              "Inventory",
              Icons.inventory,
              Colors.green,
              Container(),
            ),

            buildMenu(
              context,
              "Reports",
              Icons.bar_chart,
              Colors.purple,
              Container(),
            ),

            buildMenu(
              context,
              "Suppliers",
              Icons.local_shipping,
              Colors.red,
              Container(),
            ),

            buildMenu(
              context,
              "Logout",
              Icons.logout,
              Colors.grey,
              Container(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenu(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget page,
  ) {
    return GestureDetector(
      onTap: () {
        if (page is! Container) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
      },

      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(icon, size: 50, color: Colors.white),

            SizedBox(height: 10),

            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
