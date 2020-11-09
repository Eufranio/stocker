import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/route/routes.dart';
import 'package:stocker/screens/attribute/attribute_list.dart';
import 'package:stocker/screens/client/client_list.dart';
import 'package:stocker/screens/product/product_list.dart';
import 'package:stocker/screens/stock/stock_list.dart';

class StoreScreen extends StatelessWidget {

  Store store;

  StoreScreen(this.store);

  @override
  Widget build(BuildContext context) {
    var userRef = Provider.of<DocumentReference>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton(
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 1,
                  child: Text('Renomear'),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Text('Excluir'),
                )
              ],
            onSelected: (option) {
                if (option == 2) {
                  DocumentReference ref = Provider.of<DocumentReference>(context, listen: false);
                  var count = 0;
                  Navigator.popUntil(context, (route) => count++ == 1);

                  ref.collection('stores').document(store.id).delete();
                  return;
                }

                var key = GlobalKey<FormState>();
                showDialog(context: context, child: Form(
                  key: key,
                  child: AlertDialog(
                    title: Text('Renomeando'),
                    content: TextFormField(
                      initialValue: this.store.name,
                      validator: (val) {
                        if (val.isEmpty)
                          return 'O nome não pode ser vazio!';
                        return null;
                      },
                      autovalidate: true,
                      onSaved: (val) {
                        store.name = val;
                      },
                    ),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: () async {
                            if (key.currentState.validate()) {
                              DocumentReference ref = Provider.of<DocumentReference>(context, listen: false);

                              key.currentState.save();
                              Navigator.of(context).pop(store);

                              ref.collection('stores')
                                  .document(store.id)
                                  .setData(store.toJson());
                            }
                          },
                          child: Text('Salvar')
                      )
                    ],
                  ),
                ));
            },
          )
        ],
      ),
      body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Colors.purple, Colors.deepPurple]
              )
          ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Text(this.store.name, style: TextStyle(fontSize: 35, color: Colors.white))
                ),
              ),
              Expanded(child: GridView.count(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 30),
                shrinkWrap: true,
                crossAxisCount: (MediaQuery.of(context).size.width / 180).floor(),
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: <Widget>[
                  RaisedButton.icon(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      onPressed: () => Navigator.pushNamed(context, Routes.stockList, arguments: [userRef, store]),
                      icon: Icon(Icons.shopping_cart),
                      label: Text('Estoque'),
                      color: Colors.white.withOpacity(0.8),
                  ),
                  RaisedButton.icon(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      onPressed: () => Navigator.pushNamed(context, Routes.productList, arguments: [userRef, store]),
                      icon: Icon(Icons.category),
                      label: Text('Produtos'),
                      color: Colors.white.withOpacity(0.8),
                  ),
                  RaisedButton.icon(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      onPressed: () => Navigator.pushNamed(context, Routes.attributeList, arguments: [userRef, store]),
                      icon: Icon(Icons.edit),
                      label: Text('Atributos'),
                      color: Colors.white.withOpacity(0.8),
                  ),
                  RaisedButton.icon(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      onPressed: () {},
                      icon: Icon(Icons.receipt),
                      label: Text('Pedidos'),
                      color: Colors.white.withOpacity(0.8),
                  ),
                  RaisedButton.icon(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      onPressed: () => Navigator.pushNamed(context, Routes.clientList, arguments: [userRef, store]),
                      icon: Icon(Icons.person),
                      label: Text('Clientes'),
                      color: Colors.white.withOpacity(0.8),
                  ),
                  RaisedButton.icon(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      onPressed: () {},
                      icon: Icon(Icons.person_outline),
                      label: Text('Vendedores'),
                      color: Colors.white.withOpacity(0.8),
                  ),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}