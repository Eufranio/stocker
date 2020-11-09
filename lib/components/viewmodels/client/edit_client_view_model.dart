import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:stocker/components/models/client.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/viewmodels/client/client_view_model.dart';

class EditClientViewModel extends ClientViewModel {

  EditClientViewModel(Client client, Store store, DocumentReference userRef) :
      super(client, store, userRef);

  String validateField(String field) => (field == null || field.isEmpty) ? 'Esse campo não pode ser vazio!' : null;

  ImagePicker imagePicker = ImagePicker();

  File image;

  void saveName(String name) => client.name = name;

  void saveAddress(String address) => client.address = address;

  void saveCity(String city) => client.city = city;

  void savePhone(String phone) => client.phone = phone;

  var phoneFormatter = new MaskTextInputFormatter(mask: '(##) # ####-####', filter: { "#": RegExp(r'[0-9]') });

  Future<void> saveClient() {
    var ref = userRef.collection('stores')
        .document(store.id)
        .collection('clients')
        .document(client.id);
    return ref.setData(client.toJson()).then((value) {
      this.client.id = ref.documentID;
      return ref;
    });
  }

  Future<void> uploadImage() {
    var storage = FirebaseStorage.instance.ref()
        .child('${userRef.documentID}/stores/${store.id}/clients/${client.id}/icon.png');
    if (image != null) {
      return storage.putFile(image).onComplete
          .then((_) => storage.getDownloadURL())
          .then((url) {
            client.image_url = url;
            return saveClient();
          });
    }
    return Future.value();
  }

  Future<void> removeImage() {
    image = null;
    client.image_url = null;
    return saveClient();
  }

  Future<void> pickImage() {
    return imagePicker.getImage(source: ImageSource.gallery)
        .then((value) {
          if (value != null)
            image = File(value.path);
        });
  }


}