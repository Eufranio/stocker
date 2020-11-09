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
import 'package:stocker/components/widgets/attribute_list.dart';
import 'package:stocker/components/widgets/attribute_text.dart';
import 'package:stocker/components/widgets/cached_image.dart';

class ProductScreen extends StatefulWidget {

  final Product product;
  final Store store;

  ProductScreen(this.store, this.product);

  @override
  State createState() => _ProductScreenState();

}

class _ProductScreenState extends State<ProductScreen> {

  File image;
  String uploadedFileUrl;
  var picker = ImagePicker();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var images = Map<String, String>(); // path <> url

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(widget.product.name),
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
                    child: AttributeList(widget.store, widget.product),
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
                onPressed: () {
                  setState(() {
                    image = null;
                    widget.product.imageUrl = null;
                    context.read<DocumentReference>()
                        .collection('products')
                        .document(widget.product.id)
                        .setData(widget.product.toJson()).then((value) => scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text('Imagem removida!'),
                        duration: Duration(seconds: 2)
                    )));
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
            IconButton(
                icon: Icon(Icons.cloud_upload, color: Colors.purple),
                onPressed: () {
                  var user = context.read<User>();
                  var storage = FirebaseStorage.instance.ref()
                      .child('${user.uid}/${widget.store.id}/${widget.product.id}/icon.png');
                  if (image == null) {
                    scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text('Nenhuma imagem selecionada!'),
                      backgroundColor: Colors.redAccent,
                      duration: Duration(seconds: 2),
                    ));
                    return;
                  }
                  showDialog(context: context,
                      barrierDismissible: false,
                      builder: (ctx) {
                        storage.putFile(image).onComplete
                            .then((_) => storage.getDownloadURL())
                            .then((url) => setState(() {
                          widget.product.imageUrl = url;
                          context.read<DocumentReference>()
                              .collection('products')
                              .document(widget.product.id)
                              .setData(widget.product.toJson());
                          Navigator.pop(ctx);
                          scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text('Imagem atualizada!'),
                            duration: Duration(seconds: 2),
                          ));
                        }));
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
                  );
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
              child: CachedImage(imageFile: this.image, imageUrl: widget.product?.imageUrl),
            ),
            Container(
              color: Colors.purple.withOpacity(0.6),
              width: double.maxFinite,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: AttributeText(widget.store, widget.product),
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
        FutureBuilder(
          future: FirebaseStorage.instance.ref()
              .child('${user.uid}/${widget.store.id}/${widget.product.id}/images/')
              .listAll()
              .then((value) async {
                images.clear();
                Map<dynamic, dynamic> items = value['items'];
                await Future.forEach(items.values, (element) async {
                  await FirebaseStorage.instance.ref()
                      .child(element['path'])
                      .getDownloadURL()
                      .then((value) => images[element['path']] = value);
                });
                return images;
              }),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (images.isEmpty) {
                return Center(child: Text('Nenhuma imagem ainda!'));
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, index) => PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(child: Text('Excluir'), value: 0, height: 30),
                    PopupMenuItem(child: Text('Usar como ícone'), value: 1)
                  ],
                  onSelected: (val) async {
                    var path = images.keys.elementAt(index);
                    if (val == 0) {
                      FirebaseStorage.instance.ref()
                          .child(path)
                          .delete().then((value) {
                            return context.read<DocumentReference>()
                            .collection('products')
                            .document(widget.product.id)
                            .setData(widget.product.toJson());
                          }).then((value) => setState(() {
                            images.remove(path);
                            scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text('Imagem excluída com sucesso!'),
                              duration: Duration(seconds: 2),
                            ));
                          }));
                    } else if (val == 1) {
                      widget.product.imageUrl = images[path];
                      context.read<DocumentReference>()
                          .collection('products')
                          .document(widget.product.id)
                          .setData(widget.product.toJson())
                          .then((value) => setState(() {
                            scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text('Icone atualizado com sucesso!'),
                              duration: Duration(seconds: 2),
                            ));
                          }));
                    }
                  },
                  child: InkWell(
                    child: Card(
                      child: CachedNetworkImage(
                          imageUrl: images[images.keys.elementAt(index)],
                          height: 100,
                          placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Icon(Icons.error)
                      ),
                    ),
                  ),
                ),
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
        Positioned.fill(child: Align(
          alignment: Alignment.centerRight,
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                picker.getImage(source: ImageSource.gallery).then((value) => setState(() {
                  if (value != null) {
                    var user = context.read<User>();
                    var storage = FirebaseStorage.instance.ref()
                        .child('${user.uid}/${widget.store.id}/${widget.product.id}/images/${shortHash(UniqueKey())}.png');
                    showDialog(context: context,
                        barrierDismissible: false,
                        builder: (ctx) {
                          storage.putFile(File(value.path)).onComplete
                              .then((_) => storage.getDownloadURL())
                              .then((url) => setState(() {
                            images[storage.path] = url;
                            Navigator.pop(ctx);
                            scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text('Imagem adicionada!'),
                              duration: Duration(seconds: 2),
                            ));
                          }));
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
                    );
                  }
                }));
              },
            )
        ))
      ],
    );
  }

  void _showNewAttributeDialog(BuildContext context) {
    var key = GlobalKey<FormState>();

    AttributeType type;
    ProductAttribute selectedAttribute;

    List<ProductAttribute> currentAttributes = List();

    bool ignoring = false;

    showDialog(context: context, child: StatefulBuilder(
        builder: (context, _setState) => AlertDialog(
          title: Text('Novo Atributo'),
          content: Form(key: key, child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Padding(
                      padding: EdgeInsets.only(right: 15),
                      child: Text('Tipo')
                  ),
                  Expanded(child: StreamBuilder(
                    stream: context.watch<DocumentReference>()
                        .collection('stores')
                        .document(widget.store.id)
                        .collection('attribute_types')
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        List<AttributeType> attributes = snapshot.data.documents.map((e) =>
                            AttributeType.fromMap(e.documentID, e.data)).toList();
                        if (attributes.isEmpty)
                          return Text('Nada para mostrar');
                        return IgnorePointer(
                          ignoring: ignoring,
                          child: DropdownButtonFormField<AttributeType>(
                            items: attributes.map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.name)
                            )).toList(),
                            validator: (val) {
                              return val == null ? 'Selecione um tipo!' : null;
                            },
                            onChanged: ignoring ? null : (val) {
                              _setState(() {
                                type = val;
                              });
                            },
                            disabledHint: Text(type?.name ?? '...'),
                          ),
                        );
                      }
                      return Center(child: CircularProgressIndicator());
                    },
                  ))
                ],
              ),
              Row(
                children: [
                  Padding(
                      padding: EdgeInsets.only(right: 15),
                      child: Text('Valor')
                  ),
                  Expanded(child: StreamBuilder(
                    stream: context.watch<DocumentReference>()
                        .collection('stores')
                        .document(widget.store.id)
                        .collection('product_attributes')
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        var allAttributes = snapshot.data.documents.map((e) =>
                            ProductAttribute.fromMap(e.documentID, e.data)).toList();

                        if (type != null) {
                          currentAttributes = allAttributes.where((element) => element.type == type.id).toList();
                        }

                        if (currentAttributes.isEmpty) {
                          currentAttributes = List.from(allAttributes);
                        }
                        return DropdownButtonFormField<ProductAttribute>(
                          items: currentAttributes.map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.value)
                          )).toList(),
                          validator: (val) {
                            if (val == null)
                              return 'Selecione um valor!';
                            var productAttributes = currentAttributes.where((element) => widget.product.attributes.contains(element.id));
                            if (widget.product.attributes.contains(val.id) ||
                                productAttributes.any((element) => element.type == val.type))
                              return 'Já adicionado!';
                            return null;
                          },
                          onChanged: (val) {
                            _setState(() {
                              ignoring = true;
                            });
                          },
                          autovalidate: true,
                          onSaved: (val) => selectedAttribute = val,
                        );
                      }
                      return Center(child: CircularProgressIndicator());
                    },
                  ))
                ],
              )
            ],
          )),
          actions: [
            FlatButton(
              child: Text('Salvar'),
              onPressed: () async {
                if (key.currentState.validate()) {
                  key.currentState.save();

                  widget.product.attributes.add(selectedAttribute.id);
                  DocumentReference ref = Provider.of<DocumentReference>(context, listen: false);
                  ref.collection('products')
                      .document(widget.product.id)
                      .setData(widget.product.toJson());
                  Navigator.of(context).pop();
                }
              },
            )
          ],
        )
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
              widget.product.name = val;
              context.read<DocumentReference>()
                  .collection('products')
                  .document(widget.product.id)
                  .setData(widget.product.toJson());
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
          onPressed: () {
            var ref = context.read<DocumentReference>();

            // delete all stocks of this product
            ref.collection('products')
                .document(widget.product.id)
                .delete()
                .then((value) => ref.collection('stores')
                  .document(widget.store.id)
                  .collection('stocks')
                  .where('product', isEqualTo: widget.product.id)
                  .limit(1)
                  .getDocuments())
                .then((doc) {
                  if (doc.documents.isEmpty)
                    return Future.value();
                  
                  return doc.documents.first.reference
                      .collection('receipts')
                      .getDocuments()
                      .then((snapshot) {
                        var list = List<DocumentSnapshot>();
                        list.add(doc.documents.first);
                        list.addAll(snapshot.documents);
                        return list;
                      });
                })
                .then((value) {
                  if (value != null && value.isNotEmpty) {
                    return Future.forEach(value, (doc) => doc.reference.delete());
                  }
                  return Future.value();
                })
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

              var collectionReference = context.read<DocumentReference>()
                  .collection('stores')
                  .document(widget.store.id)
                  .collection('stocks');

              collectionReference.where('product', isEqualTo: widget.product.id)
                  .limit(1)
                  .getDocuments()
                  .then((snapshot) {
                    if (snapshot.documents.isNotEmpty) {
                      Navigator.pop(context);
                      scaffoldKey.currentState.showSnackBar(SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text('Já existe um estoque desse produto!'),
                        duration: Duration(seconds: 2),
                      ));
                    } else {
                      collectionReference.document()
                          .setData(Stock(null, amount, unit, widget.product.id).toJson())
                          .then((value) {
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