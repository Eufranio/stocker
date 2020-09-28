import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stocker/components/models/attribute_type.dart';
import 'package:stocker/components/models/product.dart';
import 'package:stocker/components/models/product_attribute.dart';
import 'package:stocker/components/models/store.dart';

class AttributeList extends StatefulWidget {

  final Store store;
  final Product product;

  AttributeList(this.store, this.product);

  @override
  State<StatefulWidget> createState() => _AttributeListState();

}

class _AttributeListState extends State<AttributeList> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: context.watch<DocumentReference>()
            .collection('stores')
            .document(widget.store.id)
            .collection('product_attributes')
            .where(FieldPath.documentId, whereIn: widget.product.attributes.isEmpty ? ['teste'] : widget.product.attributes)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            List<ProductAttribute> attributes = snapshot.data.documents.map((e) =>
                ProductAttribute.fromMap(e.documentID, e.data)).toList();
            if (attributes.isEmpty) {
              return Center(child: Text('Nada para mostrar',
                  style: TextStyle(fontSize: 24, color: Colors.purple))
              );
            }
            return ListView.builder(
                shrinkWrap: true,
                itemCount: attributes.length,
                itemBuilder: (context, index) {
                  var attribute = attributes[index];
                  return FutureBuilder(
                    future: context.watch<DocumentReference>()
                        .collection('stores')
                        .document(widget.store.id)
                        .collection('attribute_types')
                        .document(attribute.type)
                        .get(),
                    builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasData) {
                        var type = AttributeType.fromMap(
                            snapshot.data.documentID, snapshot.data.data);
                        return _buildCard(context,
                          icon: Icon(Icons.star, color: Colors.white),
                          title: Text(attribute.value, style: TextStyle(color: Colors.white, fontSize: 20)),
                          subtitle: Text(type.name, style: TextStyle(color: Colors.white)),
                          trailing: PopupMenuButton(
                            icon: Icon(Icons.more_vert, color: Colors.white),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 1,
                                child: Text('Excluir'),
                              ),
                            ],
                            onSelected: (index) {
                              setState(() {
                                widget.product.attributes.remove(attribute.id);
                                DocumentReference ref = Provider.of<DocumentReference>(context, listen: false);
                                ref.collection('products')
                                    .document(widget.product.id)
                                    .setData(widget.product.toJson());
                              });
                            },
                          ),
                        );
                      }
                      return Container(height: 80, child: Center(child: CircularProgressIndicator()));
                    },
                  );
                }
            );
          }
          return Center(child: CircularProgressIndicator());
        }
    );
  }

  Widget _buildCard(BuildContext context, {
    Widget icon,
    Widget title,
    Widget subtitle,
    Widget trailing,
    Function onTap
  }) {
    return Padding(
        padding: EdgeInsets.only(left: 8, right: 8, top: 15),
        child: InkWell(
          onTap: onTap,
          child: Card(
            child: ListTile(
              leading: icon,
              contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
              title: title,
              subtitle: subtitle,
              trailing: trailing,
            ),
          ),
        )
    );
  }
}