import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/screens/store/store_screen.dart';

class StoreListScreen extends StatefulWidget {

  final List<Store> stores = List();

  @override
  State createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  
  _showNewDialog(BuildContext context) {
    var key = GlobalKey<FormState>();
    showDialog(context: context, child: AlertDialog(
      title: Text('Criar Loja'),
      content: Form(
          key: key,
          child: TextFormField(
            autofocus: true,
            initialValue: 'Nome',
            validator: (val) => val.isEmpty ? 'O nome não pode ser vazio!' : null,
            autovalidate: true,
            onSaved: (val) {
              Provider.of<DocumentReference>(context, listen: false)
                  .collection('stores')
                  .document()
                  .setData(Store(null, val, [], []).toJson());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showNewDialog(context),
      ),
      appBar: AppBar(
        title: Text('Lojas'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _showNewDialog(context)
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: StreamBuilder(
          stream: Provider.of<DocumentReference>(context, listen: false).collection('stores').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              widget.stores.clear();
              widget.stores.addAll(snapshot.data.documents.map((e) => Store.fromMap(e.documentID, e.data)).toList());
              return SearchBar<Store>(
                hintText: 'Pesquisar',
                searchBarStyle: SearchBarStyle(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    borderRadius: BorderRadius.circular(30)
                ),
                crossAxisCount: (MediaQuery.of(context).size.width / 200).floor(),
                onSearch: (str) async {
                  return widget.stores.where((e) => e.name.contains(str)).toList();
                },
                onItemFound: (store, index) =>
                    Container(
                      color: Color.fromRGBO(142, 142, 147, .15),
                      child: ListTile(
                        title: Text(store.name, style: TextStyle(color: Colors.purple),),
                        subtitle: Text(store.id),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => StoreScreen(store)));
                        },
                      ),
                    ),
                suggestions: widget.stores,
                loader: Center(child: CircularProgressIndicator()),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              );
            }
            return Center(child: CircularProgressIndicator());
          }
        )
      )
    );
  }
}