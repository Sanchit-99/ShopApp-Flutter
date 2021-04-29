import 'package:ShopApp/providers/cart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;
  CartItem({this.id, this.price, this.quantity, this.title, this.productId});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      child: Dismissible(
       
        confirmDismiss: (direction) {
          return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Are you sure?'),
              content: Text('Do you want to remove the item from cart?'),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('No'),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Yes'),
                )
              ],
            ),
          );
        },
        direction: DismissDirection.endToStart,
        key: ValueKey(id),
        background: Container(
            padding: EdgeInsets.only(right: 10),
            alignment: Alignment.centerRight,
            color: Colors.red,
            child: Icon(
              Icons.delete,
              color: Colors.white,
              size: 35,
            )),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: FittedBox(child: Text('₹$price')),
            ),
            title: Text(title),
            subtitle: Text('Total: ₹${(price * quantity)}'),
            trailing: Text('$quantity x'),
          ),
        ),
        onDismissed: (_) {
          Provider.of<Cart>(context, listen: false).removeItem(productId);
        },
      ),
    );
  }
}
