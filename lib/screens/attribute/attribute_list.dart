import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stocker/components/models/attribute_type.dart';
import 'package:stocker/components/models/product_attribute.dart';
import 'package:stocker/components/models/store.dart';

class AttributeListScreen extends StatefulWidget {

  final Store store;
  final List<AttributeType> attributes = List();

  AttributeListScreen(this.store);

  @override
  State createState() => _AttributeListScreenState();
}

class _AttributeListScreenState extends State<AttributeListScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Atributos de ${widget.store.name}'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showCreateDialog(context),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showCreateDialog(context),
      ),
      body: Container(
        child: StreamBuilder(
          stream: context.watch<DocumentReference>()
              .collection('stores')
              .document(widget.store.id)
              .collection('attribute_types')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              widget.attributes.clear();
              widget.attributes.addAll(snapshot.data.documents.map((e) => AttributeType.fromMap(e.documentID, e.data)));
              return _buildSearchBar();
            }
            return Center(child: CircularProgressIndicator());
          }
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: SearchBar<AttributeType>(
        emptyWidget: Center(child: Text('Nada para mostrar', style: TextStyle(color: Colors.purple, fontSize: 25))),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        crossAxisCount: (MediaQuery.of(context).size.width / 200).floor(),
        hintText: 'Pesquisar',
        searchBarStyle: SearchBarStyle(
            padding: EdgeInsets.symmetric(horizontal: 10),
            borderRadius: BorderRadius.circular(30)
        ),
        onSearch: (str) async {
          return widget.attributes.where((element) => element.name.startsWith(str)).toList();
        },
        onItemFound: (attribute, index) => Container(
          color: Color.fromRGBO(142, 142, 147, .15),
          child: ListTile(
            contentPadding: EdgeInsets.all(10),
            title: Text(attribute.name, style: TextStyle(color: Colors.purple),),
            onTap: () => _showListDialog(context, attribute),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.purpleAccent,),
              onPressed: () => _showDeleteDialog(context, attribute),
            )
          ),
        ),
        suggestions: widget.attributes,
      ),
    );
  }

  _showCreateDialog(BuildContext context) {
    var key = GlobalKey<FormState>();
    showDialog(context: context, child: AlertDialog(
      title: Text('Novo Atributo'),
      content: Form(
          key: key,
          child: TextFormField(
            autofocus: true,
            initialValue: 'Nome',
            validator: (val) => val.isEmpty ? 'O nome não pode ser vazio!' : null,
            autovalidate: true,
            onSaved: (val) {
              context.read<DocumentReference>()
                  .collection('stores')
                  .document(widget.store.id)
                  .collection('attribute_types')
                  .document()
                  .setData(AttributeType(null, val).toJson());
            },
          )
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Fechar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          onPressed: () {
            if (key.currentState.validate()) {
              key.currentState.save();
              Navigator.of(context).pop();
            }
          },
          child: Text('Salvar'),
        )
      ],
    ));
  }

  _showDeleteDialog(BuildContext context, AttributeType attribute) {
    showDialog(context: context, child: AlertDialog(
        title: Text('Remover'),
        content: Text('Você tem certeza que deseja remover esse atributo?'),
        actions: <Widget>[
          FlatButton(
            child: Text('Fechar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            onPressed: () {
              context.read<DocumentReference>()
                  .collection('stores')
                  .document(widget.store.id)
                  .collection('attribute_types')
                  .document(attribute.id)
                  .delete();

              Navigator.of(context).pop();
            },
            child: Text('Remover'),
          )
        ]
    ));
  }

  _showListDialog(BuildContext context, AttributeType attribute) {
    showDialog(context: context, child: AlertDialog(
        scrollable: true,
        title: Text(attribute.name),
        content: StreamBuilder(
            stream: context.read<DocumentReference>()
                .collection('stores')
                .document(widget.store.id)
                .collection('product_attributes')
                .where('type', isEqualTo: attribute.id)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                List<ProductAttribute> attributes = snapshot.data.documents.map((e) =>
                    ProductAttribute.fromMap(e.documentID, e.data)).toList();
                return attributes.isEmpty ? Text("Nada para mostrar") : Container(
                  width: 400,
                  height: 200,
                  child: ListView.builder(
                      itemCount: attributes.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(attributes[index].value, style: TextStyle(color: Colors.purpleAccent)),
                        trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              context.read<DocumentReference>()
                                  .collection('stores')
                                  .document(widget.store.id)
                                  .collection('product_attributes')
                                  .document(attributes[index].id)
                                  .delete();
                            }
                        ),
                      )
                  )
                );
              }
              return Center(child: CircularProgressIndicator());
            }
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Fechar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('Novo'),
            onPressed: () => _showAddAttributeDialog(context, attribute)
          ),
          /*FlatButton(
            onPressed: () {
              context.read<DocumentReference>()
                  .collection('stores')
                  .document(widget.store.id)
                  .collection('attribute_types')
                  .document(attribute.id)
                  .delete();

              Navigator.of(context).pop();
            },
            child: Text('Remover'),
          )*/
        ]
    ));
  }

  _showAddAttributeDialog(BuildContext context, AttributeType type) {
    var key = GlobalKey<FormState>();
    showDialog(context: context, child: AlertDialog(
      title: Text('Novo Atributo'),
      content: Form(
          key: key,
          child: TextFormField(
            autofocus: true,
            initialValue: 'Valor',
            validator: (val) => val.trim().isEmpty ? 'O valor não pode ser vazio!' : null,
            autovalidate: true,
            onSaved: (val) {
              context.read<DocumentReference>()
                  .collection('stores')
                  .document(widget.store.id)
                  .collection('product_attributes')
                  .document()
                  .setData(ProductAttribute(null, type.id, val).toJson());
            },
          )
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Fechar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          onPressed: () {
            if (key.currentState.validate()) {
              key.currentState.save();
              Navigator.of(context).pop();
            }
          },
          child: Text('Salvar'),
        )
      ],
    ));
  }

}