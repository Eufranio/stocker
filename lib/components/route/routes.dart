import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stocker/screens/attribute/attribute_list.dart';
import 'package:stocker/screens/client/client_list.dart';
import 'package:stocker/screens/client/client_screen.dart';
import 'package:stocker/screens/client/edit_client.dart';
import 'package:stocker/screens/product/product_list.dart';
import 'package:stocker/screens/product/product_screen.dart';
import 'package:stocker/screens/receipt/edit_receipt.dart';
import 'package:stocker/screens/receipt/receipt_history.dart';
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

  static const receipt = '$stock/receipt';
  static const receiptEdit = '$receipt/edit';
  static const receiptHistory = '$receipt/history';

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

      case product:
        var store = arguments[1], product = arguments[2];
        return MaterialPageRoute(builder: (_) => ProductScreen(store, product, userRef));
      case productList:
        var store = arguments[1];
        return MaterialPageRoute(builder: (_) => ProductListScreen(store, userRef));

      case stock:
        var store = arguments[1], product = arguments[2], stock = arguments[3];
        return MaterialPageRoute(builder: (_) => StockScreen(store, product, stock, userRef));
      case stockList:
        var store = arguments[1];
        return MaterialPageRoute(builder: (_) => StockListScreen(store, userRef));

      case receipt:
      case receiptEdit:
        var store = arguments[1], stock = arguments[2], product = arguments[3], receipt = arguments[4];
        return MaterialPageRoute(builder: (_) => EditStockReceiptScreen(store, stock, product, receipt, userRef));
      case receiptHistory:
        var store = arguments[1], stock = arguments[2], product = arguments[3];
        return MaterialPageRoute(builder: (_) => ReceiptHistoryScreen(store, stock, product, userRef));
    }
  }

}