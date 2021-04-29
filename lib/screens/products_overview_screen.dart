import 'package:ShopApp/providers/products_provider.dart';
import 'package:ShopApp/screens/cart_screen.dart';
import 'package:ShopApp/widgets/app_drawer.dart';
import 'package:ShopApp/widgets/product_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/badge.dart';
import '../providers/cart.dart';

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool isFav = false;
  bool isloading = false;
  bool isempty = false;
  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      isloading = true;
      isempty = false;
    });
    Provider.of<ProductProvider>(context, listen: false)
        .fetchData()
        .then((value) {
      setState(() {
        isloading = false;
        var p = Provider.of<ProductProvider>(context, listen: false).get_items;
        if (p.isEmpty) {
          isempty = true;
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              setState(() {
                if (value == 0) {
                  isFav = true;
                } else {
                  isFav = false;
                }
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: 0,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: 1,
              ),
            ],
            icon: Icon(Icons.more_vert),
          ),
          Consumer<Cart>(
            builder: (context, cart, ch) {
              return Badge(child: ch, value: cart.itemCount.toString());
            },
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.pushNamed(context, CartScreen.screenName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: isloading
          ? Center(child: CircularProgressIndicator())
          : isempty
              ? Center(child: Text('No items'))
              : Consumer<ProductProvider>(builder: (context, value, child) {
                  final products =
                      isFav ? value.getFavoriteItems : value.get_items;
                  return GridView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (ctx, index) {
                      return ChangeNotifierProvider.value(
                        value: products[index],
                        child: ProductItem(),
                      );
                    },
                  );
                }),
    );
  }
}
