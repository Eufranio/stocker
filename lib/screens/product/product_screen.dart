import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:stocker/components/models/attribute_type.dart';
import 'package:stocker/components/models/product.dart';
import 'package:stocker/components/models/product_attribute.dart';
import 'package:stocker/components/models/stock.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/user.dart';
import 'package:stocker/components/viewmodels/product/product_view_model.dart';
import 'package:stocker/components/widgets/attribute_list.dart';
import 'package:stocker/components/widgets/attribute_text.dart';
import 'package:stocker/components/widgets/cached_image.dart';
import 'package:stocker/components/widgets/stream_utils.dart';
import 'package:stocker/screens/product/add_attribute_dialog.dart';

class ProductScreen extends StatefulWidget {

  final ProductViewModel viewModel;

  ProductScreen(Store store, Product product, DocumentReference userRef)
      : viewModel = ProductViewModel(product, store, userRef);

  @override
  State createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {

  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(widget.viewModel.product.name),
          actions: [
            PopupMenuButton(
                itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('Excluir'),
                value: 1,
              ),
              PopupMenuItem(
                child: Text('Renomear'),
                value: 2
              ),
              PopupMenuItem(
                child: Text('Novo estoque'),
                value: 3
              )
            ],
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.more_vert),
              ),
              onSelected: (index) {
                  if (index == 1) {
                    _showDeleteDialog(context);
                  } else if (index == 2) {
                    _showRenameDialog(context);
                  } else if (index == 3) {
                    _showCreateStockDialog(context);
                  }
              },
            )
          ],
        ),
        body: Container(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  _buildHeader(context),
                  Divider(
                    thickness: 5,
                  ),
                  Container(
                      height: 100,
                      width: double.infinity,
                      child: _buildImageRow(context)
                  ),
                  Divider(
                    thickness: 5,
                    indent: 80,
                    endIndent: 80,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Atributos', style: TextStyle(
                            fontSize: 25,
                            color: Colors.black45
                        )),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.purple,),
                          onPressed: () {
                            _showNewAttributeDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: AttributeList(widget.viewModel.store, widget.viewModel.product),
                  )
                ],
              ),
            )
        )
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          constraints: BoxConstraints.loose(Size(300, 300)),
          child: Padding(
            padding: EdgeInsets.all(15),
            child: _buildProductIcon(context),
          ),
        ),
        Column(
          children: [
            IconButton(
                icon: Icon(Icons.delete, color: Colors.purple),
                onPressed: () => widget.viewModel.setProductImage(null)
                    .then((_) => setState(() {}))
                    .then((_) =>
                    scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text('Imagem removida!'),
                        duration: Duration(seconds: 2)
                    ))
                ),
            ),
            IconButton(
                icon: Icon(Icons.edit, color: Colors.purple),
                onPressed: () => widget.viewModel.selectMainImage().then((_) => setState((){})),
            ),
            IconButton(
                icon: Icon(Icons.cloud_upload, color: Colors.purple),
                onPressed: () {
                  var user = context.read<User>();
                  if (!widget.viewModel.isImageSelected) {
                    scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text('Nenhuma imagem selecionada!'),
                      backgroundColor: Colors.redAccent,
                      duration: Duration(seconds: 2),
                    ));
                    return;
                  }

                  showDialog(context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        widget.viewModel.uploadImage(user).then((_) => Navigator.pop(context));
                        return AlertDialog(
                            insetPadding: EdgeInsets.zero,
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                Padding(padding: EdgeInsets.only(top: 15), child: Text(
                                  'Enviando...',
                                  style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.purple
                                  ),
                                ))
                              ],
                            )
                        );
                      }
                  )
                  .then((value) => scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('Imagem atualizada!'),
                    duration: Duration(seconds: 2),
                  )));
                }
            ),
            IconButton(
                icon: Icon(Icons.share, color: Colors.purple),
                onPressed: () {}
            )
          ],
        )
      ],
    );
  }

  Widget _buildProductIcon(BuildContext context) {
    return Card(
      color: Colors.white70,
      child: InkWell(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Container(
              child: CachedImage(imageData: widget.viewModel.imageBytes, imageUrl: widget.viewModel.product?.imageUrl),
            ),
            Container(
              color: Colors.purple.withOpacity(0.6),
              width: double.maxFinite,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: AttributeText(widget.viewModel.store, widget.viewModel.product),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImageRow(BuildContext context) {
    var user = context.watch<User>();
    return Stack(
      children: [
        widget.viewModel.fetchImages(user).asStream().streamBuilder((images) => ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            itemBuilder: (context, index) => PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(child: Text('Excluir'), value: 0, height: 30),
                PopupMenuItem(child: Text('Usar como ícone'), value: 1)
              ],
              onSelected: (val) async {
                var image = images[index];
                if (val == 0) {
                  widget.viewModel.deleteImage(image)
                      .then((_) => setState(() => scaffoldKey.currentState.showSnackBar(SnackBar(
                          content: Text('Imagem excluída com sucesso!'),
                          duration: Duration(seconds: 2),
                        ))
                      )
                  );
                } else if (val == 1) {
                  widget.viewModel.setProductImage(image.downloadUrl)
                      .then((value) => setState(() {
                        scaffoldKey.currentState.showSnackBar(SnackBar(
                          content: Text('Icone atualizado com sucesso!'),
                          duration: Duration(seconds: 2),
                        ));
                      })
                  );
                }
              },
              child: InkWell(
                child: Card(
                  child: CachedNetworkImage(
                      imageUrl: images[index].downloadUrl,
                      height: 100,
                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Icon(Icons.error)
                  ),
                ),
              ),
            )
        )),
        Positioned.fill(child: Align(
          alignment: Alignment.centerRight,
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                showDialog(context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      widget.viewModel.uploadGalleryImage(user).then((_) => Navigator.pop(context));
                      return AlertDialog(
                          insetPadding: EdgeInsets.zero,
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              Padding(padding: EdgeInsets.only(top: 15), child: Text(
                                'Enviando...',
                                style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.purple
                                ),
                              ))
                            ],
                          )
                      );
                    }
                )
                .then((value) => scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: Text('Imagem adicionada com sucesso!'),
                  duration: Duration(seconds: 2),
                )));
              },
            )
        ))
      ],
    );
  }

  void _showNewAttributeDialog(BuildContext context) {
    showDialog(context: context, child: AddAttributeDialog(
        widget.viewModel.product, widget.viewModel.store, widget.viewModel.userRef
    )).then((value) => setState((){}));
  }

  void _showRenameDialog(BuildContext context) {
    var key = GlobalKey<FormState>();
    showDialog(context: context, child: AlertDialog(
      title: Text('Renomear Produto'),
      content: Form(
          key: key,
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Novo nome',
              labelStyle: TextStyle(color: Colors.purple),
            ),
            autofocus: true,
            validator: (val) => val.isEmpty ? 'O nome não pode ser vazio!' : null,
            onSaved: (val) {
              widget.viewModel.product.name = val;
            },
          )
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            if (key.currentState.validate()) {
              key.currentState.save();
              widget.viewModel.saveProduct()
                .then((_) => Navigator.pop(context))
                .then((_) => scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: Text('Imagem removida!'),
                  duration: Duration(seconds: 2)
                )
              ));
            }
          },
          child: Text('Salvar'),
        ),
      ],
    )).then((value) => setState(() {}));
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text('Você tem certeza que deseja remover esse produto?'),
      actions: [
        FlatButton(
          child: Text('Remover'),
          onPressed: () async {
            await widget.viewModel.deleteProduct()
                .then((value) {
                  var count = 0;
                  Navigator.popUntil(context, (route) => count++ == 2);
                });
          },
        ),
        FlatButton(
            child: Text('Fechar'),
            onPressed: () {
              Navigator.pop(context);
            }
        )
      ],
    ));
  }

  void _showCreateStockDialog(BuildContext context) {
    var key = GlobalKey<FormState>();
    var amount = 0;
    var unit = 'Kg';

    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text('Novo Estoque'),
      content: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Quantidade inicial',
                  labelStyle: TextStyle(color: Colors.purple),
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty)
                    return 'O valor não pode ser vazio!';
                  int amount = int.parse(val);
                  if (amount <= 0)
                    return 'O valor precisa ser positivo!';
                  return null;
                },
                onSaved: (val) {
                  amount = int.parse(val);
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Unidade',
                  labelStyle: TextStyle(color: Colors.purple),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty)
                    return 'A unidade não pode ser vazia!';
                  return null;
                },
                onSaved: (val) {
                  unit = val;
                },
              )
            ],
          )
      ),
      actions: [
        FlatButton(
          child: Text('Criar Estoque'),
          onPressed: () {
            if (key.currentState.validate()) {
              key.currentState.save();
              widget.viewModel.getStock().then((stock) async {
                if (stock != null) {
                  Navigator.pop(context);
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    backgroundColor: Colors.redAccent,
                    content: Text('Já existe um estoque desse produto!'),
                    duration: Duration(seconds: 2),
                  ));
                  return;
                } else {
                  return widget.viewModel.createStock(amount, unit)
                      .then((_) {
                    Navigator.pop(context);
                    scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text('Estoque criado com sucesso!'),
                      duration: Duration(seconds: 2),
                    ));
                  });
                }
              });
            }
          },
        ),
      ],
    ));
  }

}