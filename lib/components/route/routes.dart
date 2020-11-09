import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/screens/attribute/attribute_list.dart';
import 'package:stocker/screens/client/client_list.dart';
import 'package:stocker/screens/client/client_screen.dart';
import 'package:stocker/screens/client/edit_client.dart';
import 'package:stocker/screens/order/order_history.dart';
import 'package:stocker/screens/order/pick_client_dialog.dart';
import 'package:stocker/screens/order/single_order.dart';
import 'package:stocker/screens/product/product_list.dart';
import 'package:stocker/screens/product/product_screen.dart';
import 'package:stocker/screens/stock/stock_list.dart';
import 'package:stocker/screens/stock/stock_screen.dart';
import 'package:stocker/screens/store/store_list.dart';
import 'package:stocker/screens/store/store_screen.dart';

class Routes {

  static const store = '/store';
  static const storeList = '$store/list';

  static const attribute = '$store/attribute';
  static const attributeList = '$attribute/list';

  static const client = '$store/client';
  static const clientList = '$client/list';
  static const clientEdit = '$client/edit';

  static const product = '$store/product';
  static const productList = '$product/list';

  static const stock = '$store/stock';
  static const stockList = '$stock/list';

  static const order = '$stock/order';
  static const orderHistory = '$order/history';
  static const orderPickClient = '$order/pick_client';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    var arguments = settings.arguments != null ? settings.arguments as List : null;
    DocumentReference userRef = arguments[0];
    switch (settings.name) {

      case store:
        var store = arguments[1];
        return MaterialPageRoute(builder: (_) => StoreScreen(store));
      case storeList:
        return MaterialPageRoute(builder: (_) => StoreListScreen());


      case attributeList:
        var store = arguments[1];
        return MaterialPageRoute(builder: (_) => AttributeListScreen(store, userRef));


      case client:
        var store = arguments[1], client = arguments[2];
        return MaterialPageRoute(builder: (_) => ClientScreen(store, client, userRef));
      case clientList:
        var store = arguments[1];
        return MaterialPageRoute(builder: (_) => ClientListScreen(store, userRef));
      case clientEdit:
        var store = arguments[1], client = arguments[2];
        return MaterialPageRoute(builder: (_) => EditClientScreen(store, client, userRef));


      case order:
        var store = arguments[1], stock = arguments[2], product = arguments[3];
        return MaterialPageRoute(builder: (_) => SingleOrderScreen(store, stock, product));
      case orderHistory:
        var store = arguments[1], stock = arguments[2];
        return MaterialPageRoute(builder: (_) => OrderHistoryScreen(store, stock));
      case orderPickClient:
        var store = arguments[1];
        return MaterialPageRoute(builder: (_) => PickClientDialog(store));


      case product:
        var store = arguments[1], product = arguments[2];
        return MaterialPageRoute(builder: (_) => ProductScreen(store, product));
      case productList:
        var store = arguments[1];
        return MaterialPageRoute(builder: (_) => ProductListScreen(store));

      case stock:
        var store = arguments[1], product = arguments[2], stock = arguments[3];
        return MaterialPageRoute(builder: (_) => StockScreen(store, product, stock));
      case stockList:
        var store = arguments[1];
        return MaterialPageRoute(builder: (_) => StockListScreen(store));

    }
  }

}