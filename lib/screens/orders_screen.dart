import 'package:flutter/material.dart';
import 'package:flutter_04_shop/providers/orders.dart' show Orders;
import 'package:flutter_04_shop/widgets/main_drawer.dart';
import 'package:flutter_04_shop/widgets/order_item.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  static const String routeName = '/Orders';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  var _isLoading = false;

  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) async {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ordersData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: ordersData.orders.length,
              itemBuilder: (context, index) =>
                  OrderItem(ordersData.orders[index]),
            ),
      drawer: MainDrawer(),
    );
  }
}
