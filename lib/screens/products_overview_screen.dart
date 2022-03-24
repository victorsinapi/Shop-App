import 'package:flutter/material.dart';
import 'package:flutter_04_shop/providers/cart.dart';
import 'package:flutter_04_shop/providers/products.dart';
import 'package:flutter_04_shop/screens/cart_screen.dart';
import 'package:flutter_04_shop/widgets/badge.dart';
import 'package:flutter_04_shop/widgets/main_drawer.dart';
import 'package:provider/provider.dart';

import '../widgets/products_grid.dart';

enum FilterOption {
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _onlyFavorites = false;
  var _isLoading = false;

  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    Provider.of<Products>(context, listen: false).fetchAndSetProducts().onError(
      (error, stackTrace) {
        setState(() {
          _isLoading = false;
        });
      },
    ).then((_) {
      setState(() {
        _isLoading = false;
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
            onSelected: (FilterOption value) {
              setState(() {
                if (value == FilterOption.All) {
                  _onlyFavorites = false;
                } else {
                  _onlyFavorites = true;
                }
              });
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text('Only favorites'),
                  value: FilterOption.Favorites,
                ),
                PopupMenuItem(
                  child: Text('Show all'),
                  value: FilterOption.All,
                ),
              ];
            },
            icon: Icon(Icons.more_vert),
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch!,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_onlyFavorites),
      drawer: MainDrawer(),
    );
  }
}
