import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stocker/components/models/product.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/route/routes.dart';
import 'package:stocker/components/viewmodels/product/product_list_view_model.dart';
import 'package:stocker/components/widgets/product_display.dart';
import 'package:stocker/components/widgets/search_bar_wrapper.dart';
import 'package:stocker/components/widgets/stream_utils.dart';
import 'package:stocker/screens/product/product_screen.dart';

class ProductListScreen extends StatefulWidget {

  final ProductListViewModel viewModel;

  ProductListScreen(Store store, DocumentReference userRef)
      : viewModel = ProductListViewModel(store, userRef);

  @override
  State createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {

  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var userRef = context.watch<DocumentReference>();
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Produtos de ${widget.viewModel.store.name}'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showCreateProductDialog(context);
        },
      ),
      body: Container(
        child: widget.viewModel.products.streamBuilder((list) => SearchBarWrapper<Product>(
            list, widget.viewModel.search,
                (product) => ProductDisplay(
                widget.viewModel.store,
                product,
                onPressed: () => Navigator.pushNamed(context, Routes.product, arguments: [userRef, widget.viewModel.store, product])
            )
        )),
      ),
    );
  }

  String name;
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
            onSaved: (val) => name = val,
          )
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            if (key.currentState.validate()) {
              key.currentState.save();
              widget.viewModel.createProduct(name)
                  .then((_) => Navigator.of(context).pop())
                  .then((_) => scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text('Produto criado com sucesso!'),
                duration: Duration(seconds: 2),
              )));
            }
          },
          child: Text('Criar'),
        ),
        FlatButton(
          child: Text('Fechar'),
          onPressed: () => Navigator.of(context).pop(),
        )
      ],
    ));
  }

}