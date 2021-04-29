import 'package:ShopApp/providers/orders.dart';
import 'package:ShopApp/providers/product.dart';
import 'package:ShopApp/widgets/app_drawer.dart';
import 'package:ShopApp/widgets/order_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  static String screenName = '/OrdersScreen';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool isloading = false;
  @override
  void initState() {
    setState(() {
      isloading = true;
    });
    Provider.of<Orders>(context, listen: false)
        .fetchandsetOrders()
        .then((value) {
      setState(() {
        isloading = false;
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
      drawer: AppDrawer(),
      body: isloading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemBuilder: (ctx, index) {
                return OrderItemWidget(
                  order: ordersData.orders[index],
                );
              },
              itemCount: ordersData.orders.length,
            ),
    );
  }
}
