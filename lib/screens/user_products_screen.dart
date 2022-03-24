import 'package:flutter/material.dart';
import 'package:flutter_04_shop/providers/products.dart';
import 'package:flutter_04_shop/widgets/main_drawer.dart';
import 'package:flutter_04_shop/widgets/user_product_item.dart';
import 'package:provider/provider.dart';

import 'edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  static const routeName = '/userProducts';
  @override
  Widget build(BuildContext context) {
    //final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      drawer: MainDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<Products>(
                      builder: (context, productsData, child) => Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: productsData.items.length,
                          itemBuilder: (context, index) {
                            return Column(children: [
                              UserProductItem(
                                productsData.items[index].id,
                                productsData.items[index].title,
                                productsData.items[index].imageUrl,
                              ),
                              Divider()
                            ]);
                          },
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
