import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stocker/components/models/attribute_type.dart';
import 'package:stocker/components/models/product_attribute.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/viewmodels/base_view_model.dart';

class AttributeViewModel extends BaseViewModel {

  AttributeViewModel(this.store, DocumentReference userRef) : super(userRef);

  final Store store;

  String get appBarTitle => 'Atributos de ${store.name}';

  Stream<List<AttributeType>> get attributeTypes => userRef.collection('stores')
        .document(store.id)
        .collection('attribute_types')
        .snapshots()
        .map((snapshot) => snapshot.documents.map((e) => AttributeType.fromMap(e.documentID, e.data)).toList().cast<AttributeType>());

  Stream<List<ProductAttribute>> getProductAttributes(AttributeType attribute) => userRef.collection('stores')
      .document(store.id)
      .collection('product_attributes')
      .where('type', isEqualTo: attribute.id)
      .snapshots()
      .map((snapshot) => snapshot.documents.map((e) => ProductAttribute.fromMap(e.documentID, e.data)).toList().cast<ProductAttribute>());

  Future<List<AttributeType>> search(String str) async {
    return attributeTypes.first.then((list) => list.where((element) => element.name.toLowerCase().startsWith(str.toLowerCase())).toList());
  }

  Future<void> deleteAttributeType(AttributeType attributeType) => userRef.collection('stores')
      .document(store.id)
      .collection('attribute_types')
      .document(attributeType.id)
      .delete();

  Future<void> deleteProductAttribute(ProductAttribute attribute) => userRef.collection('stores')
      .document(store.id)
      .collection('product_attributes')
      .document(attribute.id)
      .delete();

}