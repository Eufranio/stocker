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

class EditClientScreen extends StatefulWidget {

  final Store store;
  final Client client;

  EditClientScreen(this.store, this.client);

  @override
  State createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {

  var picker = ImagePicker();
  var formKey = GlobalKey<FormState>();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var phoneFormatter = new MaskTextInputFormatter(mask: '(##) # ####-####', filter: { "#": RegExp(r'[0-9]') });
  File image;

  @override
  Widget build(BuildContext context) {
    var name = TextFormField(
      decoration: InputDecoration(labelText: 'Nome'),
      initialValue: widget.client.name,
      validator: (val) {
        if (val == null || val.isEmpty)
          return 'Preencha este campo!';
        return null;
      },
      onSaved: (val) {
        widget.client.name = val;
      },
    );

    var address = TextFormField(
      initialValue: widget.client.address,
      decoration: InputDecoration(labelText: 'Endereço'),
      validator: (val) {
        if (val == null || val.isEmpty)
          return 'Preencha este campo!';
        return null;
      },
      onSaved: (val) {
        widget.client.address = val;
      },
    );

    var city = TextFormField(
      initialValue: widget.client.city,
      decoration: InputDecoration(labelText: 'Cidade'),
      validator: (val) {
        if (val == null || val.isEmpty)
          return 'Preencha este campo!';
        return null;
      },
      onSaved: (val) {
        widget.client.city = val;
      },
    );

    var phone = TextFormField(
      initialValue: widget.client.phone,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: 'Telefone'),
      inputFormatters: [phoneFormatter],
      validator: (val) {
        if (val == null || val.isEmpty)
          return 'Preencha este campo!';
        return null;
      },
      onSaved: (val) {
        widget.client.phone = val;
      },
    );

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
                  var ref = context.read<DocumentReference>()
                      .collection('stores')
                      .document(widget.store.id)
                      .collection('clients')
                      .document(widget.client.id);
                  ref.setData(widget.client.toJson())
                      .then((_) {
                    var user = context.read<User>();
                    var storage = FirebaseStorage.instance.ref()
                        .child('${user.uid}/stores/${widget.store.id}/clients/${ref.documentID}/icon.png');
                    if (image != null) {
                      storage.putFile(image).onComplete
                          .then((_) => storage.getDownloadURL())
                          .then((url) => setState(() {
                        widget.client.image_url = url;
                        context.read<DocumentReference>()
                            .collection('stores')
                            .document(widget.store.id)
                            .collection('clients')
                            .document(ref.documentID)
                            .setData(widget.client.toJson())
                            .then((_) {
                          var count = 0;
                          Navigator.popUntil(context, (route) => count++ == 2);
                        });
                      }));
                    } else {
                      var count = 0;
                      Navigator.popUntil(context, (route) => count++ == 2);
                    }
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
                onPressed: () {
                  setState(() {
                    image = null;
                    widget.client.image_url = null;
                    scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text('Imagem removida!'),
                        duration: Duration(seconds: 2)
                    ));
                  });
                }
            ),
            IconButton(
                icon: Icon(Icons.edit, color: Colors.purple),
                onPressed: () {
                  picker.getImage(source: ImageSource.gallery).then((value) => setState(() {
                    if (value != null)
                      image = File(value.path);
                  }));
                }
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
          child: _getImage(),
        ),
      ),
    );
  }

  Widget _getImage() {
    if (image != null)
      return Image.file(image);
    if (widget.client.image_url == null)
      return FlutterLogo(size: 150);
    return CachedNetworkImage(
        imageUrl: widget.client.image_url,
        height: 200,
        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => Icon(Icons.error)
    );
  }

}