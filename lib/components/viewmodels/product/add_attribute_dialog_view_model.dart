import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stocker/components/models/attribute_type.dart';
import 'package:stocker/components/models/product.dart';
import 'package:stocker/components/models/product_attribute.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/viewmodels/product/product_view_model.dart';

class AddAttributeDialogViewModel extends ProductViewModel {

  AddAttributeDialogViewModel(Product product, Store store, DocumentReference userRef)
      : super(product, store, userRef);

  AttributeType selectedAttributeType;
  ProductAttribute selectedProductAttribute;

  bool get ignoreAttributeTypeField => selectedAttributeType != null;

  Stream<List<AttributeType>> get attributeTypes => userRef.collection('stores')
      .document(store.id)
      .collection('attribute_types')
      .snapshots()
      .map((snapshot) => snapshot.documents.map((e) => AttributeType.fromMap(e.documentID, e.data)).toList().cast<AttributeType>());

  Stream<List<ProductAttribute>> get productAttributes => userRef.collection('stores')
      .document(store.id)
      .collection('product_attributes')
      .snapshots()
      .map((snapshot) => snapshot.documents.map((e) => ProductAttribute.fromMap(e.documentID, e.data)))
      .map((attributes) => selectedAttributeType != null ? attributes.where((att) => att.type == selectedAttributeType.id) : attributes)
      .map((iterable) => iterable.toList().cast<ProductAttribute>());

  String validateAttributeType(AttributeType type) => type == null ? 'Selecione um tipo!' : null;

  String validateProductAttribute(ProductAttribute attribute, List<ProductAttribute> attributes) {
    if (attribute == null)
      return 'Selecione um valor!';
    var productAttributes = attributes.where((att) => product.attributes.contains(att.id));
    if (product.attributes.contains(attribute.id) ||
        productAttributes.any((element) => element.type == attribute.type))
      return 'Já adicionado!';
    return null;
  }

  Future<void> saveSelectedAttribute() {
    product.attributes.add(selectedProductAttribute.id);
    return userRef.collection('products')
        .document(product.id)
        .setData(product.toJson());
  }

}