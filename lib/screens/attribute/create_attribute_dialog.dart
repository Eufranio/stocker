import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/viewmodels/attribute/create_attribute_dialog_view_model.dart';

class CreateAttributeDialogScreen extends StatelessWidget {

  final CreateAttributeDialogViewModel viewModel;

  CreateAttributeDialogScreen(Store store, DocumentReference userRef) :
        this.viewModel = CreateAttributeDialogViewModel(store, userRef);

  @override
  Widget build(BuildContext context) {
    var key = GlobalKey<FormState>();
    return AlertDialog(
      title: Text('Adicionar Novo Atributo'),
      content: Form(
          key: key,
          child: TextFormField(
            autovalidate: true,
            autofocus: true,
            initialValue: 'Valor',
            validator: viewModel.validateValue,
            onSaved: viewModel.saveValue,
          )
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          onPressed: () {
            if (key.currentState.validate()) {
              key.currentState.save();
              viewModel.createNewAttribute()
                  .then((value) => Navigator.of(context).pop(true));
            }
          },
          child: Text('Criar'),
        )
      ],
    );
  }
}