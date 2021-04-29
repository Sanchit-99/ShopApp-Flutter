import 'package:ShopApp/providers/cart.dart' show Cart;
import 'package:ShopApp/widgets/cart_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  static String screenName = '/CartScreen';
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Row(
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Chip(label: Text('₹${cart.totalAmount.toStringAsFixed(2)}')),
                  Spacer(),
                  Order_button(cart: cart)
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, index) {
                return CartItem(
                  id: cart.items.values.toList()[index].id,
                  price: cart.items.values.toList()[index].price,
                  quantity: cart.items.values.toList()[index].quantity,
                  title: cart.items.values.toList()[index].title,
                  productId: cart.items.keys.toList()[index],
                );
              },
              itemCount: cart.itemCount,
            ),
          )
        ],
      ),
    );
  }
}

class Order_button extends StatefulWidget {
  const Order_button({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _Order_buttonState createState() => _Order_buttonState();
}

class _Order_buttonState extends State<Order_button> {
  var isLoading=false;
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: (widget.cart.totalAmount <=0 || isLoading )? null : () async {
        setState(() {
          isLoading=true;
        });
        await Provider.of<Orders>(context, listen: false).addOrder(
            widget.cart.items.values.toList(), widget.cart.totalAmount);
        widget.cart.clear();
        setState(() {
          isLoading=false;
        });
      },
      child: isLoading? CircularProgressIndicator(): Text(
        'ORDER NOW',
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
    );
  }
}
