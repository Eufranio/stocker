import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stocker/components/models/product.dart';
import 'package:stocker/components/models/product_attribute.dart';
import 'package:stocker/components/models/store.dart';

class AttributeText extends StatelessWidget {

  final Store store;
  final Product product;

  AttributeText(this.store, this.product);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.watch<DocumentReference>()
          .collection('stores')
          .document(store.id)
          .collection('product_attributes')
          .where(FieldPath.documentId, whereIn: product.attributes.isEmpty ? ['test'] : product.attributes)
          .getDocuments(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var list = snapshot.data.documents
              .map((doc) => ProductAttribute.fromMap(doc.documentID, doc.data))
              .toList();
          return Text(
              list.isEmpty ?
              product.name :
              list.map((e) => e.value).join(" "), style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          );
        }
        return Text('Carregando...', style: TextStyle(color: Colors.white));
      },
    );
  }
}