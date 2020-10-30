import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/viewmodels/attribute/create_attribute_type_dialog_view_model.dart';

class CreateAttributeTypeDialogScreen extends StatelessWidget {

  final CreateAttributeTypeDialogViewModel viewModel;

  CreateAttributeTypeDialogScreen(Store store, DocumentReference userRef) :
        this.viewModel = CreateAttributeTypeDialogViewModel(store, userRef);

  @override
  Widget build(BuildContext context) {
    var key = GlobalKey<FormState>();
    return AlertDialog(
      title: Text('Novo Atributo'),
      content: Form(
          key: key,
          child: TextFormField(
            autovalidate: true,
            autofocus: true,
            initialValue: 'Nome',
            validator: viewModel.validateName,
            onSaved: viewModel.saveName
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
              viewModel.createNewAttributeType()
                  .then((value) => Navigator.of(context).pop(true));
            }
          },
          child: Text('Criar'),
        )
      ],
    );
  }
}