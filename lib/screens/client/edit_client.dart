import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:stocker/components/models/client.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/user.dart';
import 'package:stocker/components/viewmodels/client/edit_client_view_model.dart';
import 'package:stocker/components/widgets/cached_image.dart';

class EditClientScreen extends StatefulWidget {

  final EditClientViewModel viewModel;

  EditClientScreen(Store store, Client client, DocumentReference userRef) :
      viewModel = EditClientViewModel(client, store, userRef);

  @override
  State createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {

  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var name = TextFormField(
      decoration: InputDecoration(labelText: 'Nome'),
      initialValue: widget.viewModel.client.name,
      validator: widget.viewModel.validateField,
      onSaved: widget.viewModel.saveName,
    );

    var address = TextFormField(
      initialValue: widget.viewModel.client.address,
      decoration: InputDecoration(labelText: 'Endereço'),
      validator: widget.viewModel.validateField,
      onSaved: widget.viewModel.saveAddress,
    );

    var city = TextFormField(
      initialValue: widget.viewModel.client.city,
      decoration: InputDecoration(labelText: 'Cidade'),
      validator: widget.viewModel.validateField,
      onSaved: widget.viewModel.saveCity,
    );

    var phone = TextFormField(
      initialValue: widget.viewModel.client.phone,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: 'Telefone'),
      inputFormatters: [widget.viewModel.phoneFormatter],
      validator: widget.viewModel.validateField,
      onSaved: widget.viewModel.savePhone,
    );

    var formKey = GlobalKey<FormState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Novo Cliente'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () {
          if (formKey.currentState.validate()) {
            formKey.currentState.save();
            showDialog(context: context,
                barrierDismissible: false,
                builder: (ctx) {
                  widget.viewModel.saveClient()
                    .then((ref) => widget.viewModel.uploadImage())
                    .then((_) {
                      var count = 0;
                      Navigator.popUntil(context, (route) => count++ == 2);
                    });
                  return AlertDialog(
                      insetPadding: EdgeInsets.zero,
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          Padding(padding: EdgeInsets.only(top: 15), child: Text(
                            'Salvando...',
                            style: TextStyle(
                                fontSize: 24,
                                color: Colors.purple
                            ),
                          ))
                        ],
                      )
                  );
                }
            );
          }
        },
      ),
      body: Container(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Padding(padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10), child: name),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10), child: address),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: Padding(padding: EdgeInsets.fromLTRB(25, 10, 5, 10), child: city)),
                          Expanded(child: Padding(padding: EdgeInsets.fromLTRB(5, 10, 25, 10), child: phone)),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 300,
          child: Padding(
            padding: EdgeInsets.all(15),
            child: _buildImage(context),
          ),
        ),
        Column(
          children: [
            IconButton(
                icon: Icon(Icons.delete, color: Colors.purple),
                onPressed: () => widget.viewModel.removeImage().then((_) =>
                    scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text('Imagem removida!'),
                        duration: Duration(seconds: 2)
                    ))
                )
            ),
            IconButton(
                icon: Icon(Icons.edit, color: Colors.purple),
                onPressed: widget.viewModel.pickImage,
            ),
          ],
        )
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    return Card(
      color: Colors.white70,
      child: InkWell(
        child: Container(
          height: 200,
          child: CachedImage(
            imageUrl: widget.viewModel.client.image_url,
            defaultImageHeight: 150,
            height: 150,
          ),
        ),
      ),
    );
  }

}