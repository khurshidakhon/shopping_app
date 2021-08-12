import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/providers/orders.dart' show Orders;
import 'package:shopping_app/screens/app_drawer.dart';
import '../widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = 'orders';
  @override
  Widget build(BuildContext context) {
    final orderedData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your orsers'),
      ),
      drawer: AppDrawer(),
      body: ListView.builder(
        itemBuilder: (ctx, index) => OrderItem(
          orderedData.orders[index],
        ),
        itemCount: orderedData.orders.length,
      ),
    );
  }
}
