import 'package:flutter/material.dart';
import 'package:flutter_04_shop/providers/auth.dart';
import 'package:flutter_04_shop/providers/cart.dart';
import 'package:flutter_04_shop/providers/orders.dart';
import 'package:flutter_04_shop/screens/cart_screen.dart';
import 'package:flutter_04_shop/screens/edit_product_screen.dart';
import 'package:flutter_04_shop/screens/orders_screen.dart';
import 'package:flutter_04_shop/screens/products_overview_screen.dart';
import 'package:flutter_04_shop/screens/splash_screen.dart';
import 'package:flutter_04_shop/screens/user_products_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_04_shop/screens/product_detail_screen.dart';

import '../screens/auth_screen.dart';

import '../providers/products.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (ctx, auth, previousProducts) => Products(
            auth.token,
            auth.userId,
            previousProducts == null ? [] : previousProducts.items,
          ),
          create: (ctx) => Products("", "", []),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (ctx, auth, previousOrders) => Orders(
            auth.token!,
            auth.userId!,
            previousOrders == null ? [] : previousOrders.orders,
          ),
          create: (ctx) => Orders("", "", []),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
              colorScheme: ColorScheme.fromSwatch()
                  .copyWith(secondary: Colors.green, primary: Colors.red),
              fontFamily: 'Lato,'),
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResSnapshot) =>
                      authResSnapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen()),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
