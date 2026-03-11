import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductScreen extends StatelessWidget {
  final List<Product> products = [
    Product(id: "1", name: "Milk", price: 2.5, quantity: 50),
    Product(id: "2", name: "Bread", price: 1.2, quantity: 30),
    Product(id: "3", name: "Apple", price: 3.0, quantity: 40),
    Product(id: "4", name: "Orange", price: 2.8, quantity: 35),
    Product(id: "5", name: "Eggs", price: 4.0, quantity: 60),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Products"), backgroundColor: Colors.green),

      body: ListView.builder(
        itemCount: products.length,

        itemBuilder: (context, index) {
          final product = products[index];

          return Card(
            margin: EdgeInsets.all(10),

            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.shopping_bag, color: Colors.white),
              ),

              title: Text(
                product.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Price: \$${product.price}"),
                  Text("Stock: ${product.quantity}"),
                ],
              ),

              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),

                child: Text("Add"),

                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${product.name} added to cart")),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
