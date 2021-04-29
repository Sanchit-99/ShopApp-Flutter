import 'package:ShopApp/providers/auth.dart';
import 'package:ShopApp/screens/auth_screen.dart';
import 'package:ShopApp/screens/cart_screen.dart';
import 'package:ShopApp/screens/edit_product.dart';
import 'package:ShopApp/screens/orders_screen.dart';
import 'package:ShopApp/screens/product_detail_screen.dart';
import 'package:ShopApp/screens/splash_screen.dart';
import 'package:ShopApp/screens/user_products_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/products_provider.dart';
import './screens/products_overview_screen.dart';
import './providers/cart.dart';
import './providers/orders.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => Auth()),
          ChangeNotifierProxyProvider<Auth, ProductProvider>(
            update: (context, auth, previous) => ProductProvider(auth.token,
                previous == null ? [] : previous.items, auth.userId),
            create: null,
          ),
          ChangeNotifierProvider(create: (context) => Cart()),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: null,
            update: (context, value, previous) => Orders(
              previous == null ? [] : previous.orders,
              value.token,
              value.userId,
            ),
          ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            home: auth.isAuth
                ? ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (context, snapshot) =>
                        snapshot.connectionState == ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen()),
            theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato',
            ),
            routes: {
              ProductDetailScreen.screenName: (ctx) => ProductDetailScreen(),
              CartScreen.screenName: (ctx) => CartScreen(),
              OrdersScreen.screenName: (ctx) => OrdersScreen(),
              UserProductsScreen.screenName: (ctx) => UserProductsScreen(),
              EditProductScreen.screenName: (ctx) => EditProductScreen(),
            },
          ),
        ));
  }
}
