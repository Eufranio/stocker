import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stocker/components/models/attribute_type.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/viewmodels/attribute/attribute_list_view_model.dart';
import 'package:stocker/components/widgets/search_bar_wrapper.dart';
import 'package:stocker/components/widgets/stream_utils.dart';
import 'package:stocker/screens/attribute/create_attribute_dialog.dart';
import 'package:stocker/screens/attribute/create_attribute_type_dialog.dart';

class AttributeListScreen extends StatefulWidget {

  final AttributeViewModel viewModel;

  AttributeListScreen(Store store, DocumentReference userRef) :
        viewModel = AttributeViewModel(store, userRef);

  @override
  State createState() => _AttributeListScreenState();

}

class _AttributeListScreenState extends State<AttributeListScreen> {

  var key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: Text(widget.viewModel.appBarTitle),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showCreateAttributeTypeDialog(context).then((value) {
          if (value == true) {
            key.currentState.showSnackBar(SnackBar(
              content: Text('Novo tipo de atributo adicionado com sucesso!'),
              backgroundColor: Colors.purple,
              duration: Duration(seconds: 2),
            ));
          }
        }),
      ),
      body: Container(
        child: widget.viewModel.attributeTypes.streamBuilder((list) => SearchBarWrapper(list, widget.viewModel.search, _buildItem))
      ),
    );
  }

  Widget _buildItem(AttributeType item) {
    return Container(
      color: Color.fromRGBO(142, 142, 147, .15),
      child: ListTile(
          contentPadding: EdgeInsets.all(10),
          title: Text(item.name, style: TextStyle(color: Colors.purple),),
          onTap: () => _showListDialog(context, item),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.purpleAccent,),
            onPressed: () => _showDeleteDialog(context, item).then((value) {
              if (value == true) {
                key.currentState.showSnackBar(SnackBar(
                  content: Text('Tipo de atributo removido com sucesso!'),
                  backgroundColor: Colors.purple,
                  duration: Duration(seconds: 2),
                ));
              }
            }),
          )
      ),
    );
  }

  _showCreateAttributeDialog(BuildContext context, AttributeType type) {
    showDialog(
        context: context,
        child: CreateAttributeDialogScreen(
            widget.viewModel.store, widget.viewModel.userRef))
        .then((value) {
      if (value == true) {
        key.currentState.showSnackBar(SnackBar(
          content: Text('Novo atributo adicionado com sucesso!'),
          backgroundColor: Colors.purple,
          duration: Duration(seconds: 2),
        ));
      }
    });
  }

  Future _showCreateAttributeTypeDialog(BuildContext context) {
    return showDialog(
        context: context,
        child: CreateAttributeTypeDialogScreen(
            widget.viewModel.store, widget.viewModel.userRef)
    );
  }

  Future _showDeleteDialog(BuildContext context, AttributeType attribute) {
    return showDialog(context: context, child: AlertDialog(
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
            onPressed: () => widget.viewModel.deleteAttributeType(attribute)
                .then((value) => Navigator.of(context).pop(true)),
            child: Text('Remover'),
          )
        ]
    ));
  }

  _showListDialog(BuildContext context, AttributeType attribute) {
    showDialog(context: context, child: AlertDialog(
        scrollable: true,
        title: Text(attribute.name),
        content: widget.viewModel.getProductAttributes(attribute)
            .streamBuilder((attributes) {
          return attributes.isEmpty ? Text("Nada para mostrar") : Container(
              width: 400,
              height: 200,
              child: ListView.builder(
                  itemCount: attributes.length,
                  itemBuilder: (context, index) =>
                      ListTile(
                        title: Text(attributes[index].value, style: TextStyle(color: Colors.purpleAccent)),
                        trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => widget.viewModel.deleteProductAttribute(attributes[index])
                        ),
                      )
              )
          );
        }),
        actions: <Widget>[
          FlatButton(
            child: Text('Fechar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FlatButton(
              child: Text('Novo'),
              onPressed: () => _showCreateAttributeDialog(context, attribute)
          ),
        ]
    ));
  }

}