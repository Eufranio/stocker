import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stocker/components/models/product.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/widgets/product_display.dart';
import 'package:stocker/screens/product/product_screen.dart';

class ProductListScreen extends StatefulWidget {

  final Store store;

  ProductListScreen(this.store);

  @override
  State createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {

  var products = List<Product>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Produtos de ${widget.store.name}'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showCreateProductDialog(context);
        },
      ),
      body: Container(
        child: StreamBuilder(
          stream: Provider.of<DocumentReference>(context, listen: false)
              .collection('products')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              this.products = snapshot.data.documents.map((e) => Product.fromMap(e.documentID, e.data)).toList();
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
        child: SearchBar<Product>(
          emptyWidget: Center(child: Text('Nada para mostrar', style: TextStyle(color: Colors.purple, fontSize: 25))),
          crossAxisCount: (MediaQuery.of(context).size.width / 200).floor(),
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
                .then((products) => products.where((product) => product.name.toLowerCase().startsWith(str.toLowerCase())).toList());
          },
          suggestions: products,
          onItemFound: (product, index) => _buildProduct(product),
        )
    );
  }

  void _showCreateProductDialog(BuildContext context) {
    var key = GlobalKey<FormState>();
    showDialog(context: context, child: AlertDialog(
      title: Text('Novo Produto'),
      content: Form(
          key: key,
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Nome',
              labelStyle: TextStyle(color: Colors.purple),
            ),
            autofocus: true,
            validator: (val) => val.isEmpty ? 'O nome não pode ser vazio!' : null,
            onSaved: (val) {
              context.read<DocumentReference>()
                  .collection('products')
                  .document()
                  .setData(Product(null, val, null, []).toJson());
            },
          )
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            if (key.currentState.validate()) {
              key.currentState.save();
              Navigator.of(context).pop();
            }
          },
          child: Text('Criar'),
        ),
        FlatButton(
          child: Text('Fechar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    ));
  }

  Widget _buildProduct(Product product) {
    return ProductDisplay(widget.store, product, onPressed: () {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ProductScreen(product, widget.store)));
    },);
  }

}