import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stocker/components/models/product.dart';
import 'package:stocker/components/models/stock.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/route/routes.dart';
import 'package:stocker/components/widgets/product_display.dart';
import 'package:stocker/screens/stock/stock_screen.dart';

class StockListScreen extends StatefulWidget {

  final Store store;
  final List<Stock> stocks = List();

  StockListScreen(this.store);

  @override
  State createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estoques de ${widget.store.name}'),
      ),
      body: Container(
        child: StreamBuilder(
          stream: Provider.of<DocumentReference>(context, listen: false)
              .collection('stores')
              .document(widget.store.id)
              .collection('stocks')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              widget.stocks.clear();
              widget.stocks.addAll(snapshot.data.documents.map((e) => Stock.fromMap(e.documentID, e.data)).toList());
              return _buildSearchBar();
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: SearchBar<Stock>(
          emptyWidget: Center(child: Text('Nada para mostrar', style: TextStyle(color: Colors.purple, fontSize: 25))),
          crossAxisCount: (MediaQuery.of(context).size.width / 400).floor(),
          hintText: 'Pesquisar',
          searchBarStyle: SearchBarStyle(
              padding: EdgeInsets.symmetric(horizontal: 10),
              borderRadius: BorderRadius.circular(30)
          ),
          onSearch: (str) {
            return Provider.of<DocumentReference>(context, listen: false)
                .collection('products')
                .getDocuments()
                .then((docs) => docs.documents.map((doc) => Product.fromMap(doc.documentID, doc.data)))
                .then((products) => products.where((product) => product.name.toLowerCase().startsWith(str.toLowerCase())))
                .then((products) => widget.stocks.where((stock) => products.any((prod) => prod.id == stock.product)).toList());
          },
          suggestions: widget.stocks,
          onItemFound: (stock, index) => _buildProduct(stock),
      )
    );
  }

  Widget _buildProduct(Stock stock) {
    var userRef = context.read<DocumentReference>();
    return FutureBuilder(
      future: userRef.collection('products')
          .document(stock.product)
          .get(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.data == null) {
            return Text('No product');
          }
          var product = Product.fromMap(snapshot.data.documentID, snapshot.data.data);
          return Row(
            children: [
              Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text('Qtd', style: TextStyle(fontSize: 15, color: Colors.black54)),
                      Text('${stock.quantity}', style: TextStyle(fontSize: 35, color: Colors.green)),
                      Text(stock.unity, style: TextStyle(fontSize: 18, color: Colors.black54))
                    ],
                  )
              ),
              Expanded(
                child: ProductDisplay(
                  widget.store,
                  product,
                  height: 150,
                  onPressed: () => Navigator.pushNamed(context, Routes.stock, arguments: [userRef, widget.store, stock, product])
                ),
              )
            ],
          );
        }
        return Container(height: 200, child: Center(child: CircularProgressIndicator()));
      }
    );
  }

}