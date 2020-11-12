import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stocker/components/models/attribute_type.dart';
import 'package:stocker/components/models/product.dart';
import 'package:stocker/components/models/stock.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/user.dart';
import 'package:stocker/components/viewmodels/store/store_view_model.dart';

class ProductViewModel extends StoreViewModel {

  final Product product;

  ProductViewModel(this.product, Store store, DocumentReference userRef)
      : super(store, userRef);

  var picker = ImagePicker();

  Uint8List imageBytes;

  bool get isImageSelected => imageBytes != null;

  Stream<List<AttributeType>> get attributeTypes => userRef.collection('stores')
      .document(store.id)
      .collection('attribute_types')
      .snapshots()
      .map((snapshot) => snapshot.documents.map((e) => AttributeType.fromMap(e.documentID, e.data)).toList().cast<AttributeType>());

  Future<void> saveProduct() => userRef.collection('products')
      .document(product.id)
      .setData(product.toJson());

  Future<void> setProductImage(String url) {
    product.imageUrl = url;
    return saveProduct();
  }

  Future<Uint8List> pickImage() => picker.getImage(source: ImageSource.gallery)
      .then((file) => file.readAsBytes());

  Future<void> selectMainImage() => this.pickImage()
      .then((bytes) => imageBytes = bytes);

  Future<void> uploadImage(User user) {
    var storage = FirebaseStorage.instance.ref()
        .child('${user.uid}/${store.id}/${product.id}/icon.png');
    return storage.putData(imageBytes, StorageMetadata(contentType: 'image/png')).onComplete
        .then((_) => storage.getDownloadURL())
        .then((url) => this.setProductImage(url));
  }

  Future<void> uploadGalleryImage(User user) {
    return this.pickImage().then((bytes) {
      var storage = FirebaseStorage.instance.ref()
          .child('${user.uid}/${store.id}/${product.id}/images/${shortHash(UniqueKey())}.png');
      return storage.putData(imageBytes, StorageMetadata(contentType: 'image/png'))
          .onComplete;
    });
  }

  Future<List<ImageReference>> fetchImages(User user) {
    var all = FirebaseStorage.instance.ref()
        .child('${user.uid}/${store.id}/${product.id}/images')
        .listAll();
    return all.then((value) => value['items'])
        .then((json) =>
          Future.wait(json['items'].values.map((e) =>
              FirebaseStorage.instance.ref()
                  .child(e['path'])
                  .getDownloadURL()
                  .then((url) => ImageReference(e['path'], url))
          ))
    );
  }

  Future<DocumentReference> getStock() => userRef.collection('stores')
      .document(store.id)
      .collection('stocks')
      .where('product', isEqualTo: product.id)
      .limit(1)
      .getDocuments()
      .then((value) => value.documents.isEmpty ? null : value.documents.first.reference);

  Future<void> createStock(int initialAmount, String unit) =>
      storeRef.collection('stocks').document().setData(Stock(null, initialAmount, unit, product.id).toJson());

  Future<void> deleteImage(ImageReference reference) => FirebaseStorage.instance.ref()
      .child(reference.path)
      .delete();

  Future<DocumentReference> deleteStock() async {
    var doc = await this.getStock();
    if (doc != null)
      await doc.delete();
    return doc;
  }

  Future<dynamic> deleteReceipts(DocumentReference stock) {
    if (stock != null) {
      return stock.collection('receipts')
          .getDocuments()
          .then((docs) => Future.forEach(docs.documents, (snapshot) => snapshot.reference.delete()));
    }
  }

  Future<void> deleteProduct() {
    return this.deleteStock()
        .then((stock) => this.deleteReceipts(stock))
        .then((value) =>
            userRef.collection('products')
                .document(product.id)
                .delete()
    );
  }

}

class ImageReference {
  final String path;
  final String downloadUrl;
  ImageReference(this.path, this.downloadUrl);
}