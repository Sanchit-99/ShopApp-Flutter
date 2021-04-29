import 'package:ShopApp/providers/product.dart';
import 'package:ShopApp/providers/products_provider.dart';
import 'package:ShopApp/screens/edit_product.dart';
import 'package:ShopApp/widgets/app_drawer.dart';
import 'package:ShopApp/widgets/user_product_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProductsScreen extends StatelessWidget {
  static String screenName = '/UserProductsScreen';

  Future<void> refresh(BuildContext context) async {
    await Provider.of<ProductProvider>(context, listen: false).fetchData(true);
  }

  @override
  Widget build(BuildContext context) {
    // final products = Provider.of<ProductProvider>(context);
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('User Products'),
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.screenName);
              }),
        ],
      ),
      body: FutureBuilder(
        future: refresh(context),
        builder: (ctx, data) => data.connectionState == ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () => refresh(context),
                child: Consumer<ProductProvider>(
                  builder: (context, products, child) => 
                                  Padding(
                    padding: EdgeInsets.all(8),
                    child: ListView.builder(
                      itemBuilder: (ctx, index) {
                        return UserProductItem(
                          imageurl: products.get_items[index].imageUrl,
                          title: products.get_items[index].title,
                          id: products.get_items[index].id,
                          deleteProduct: products.deleteProduct,
                        );
                      },
                      itemCount: products.get_items.length,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
