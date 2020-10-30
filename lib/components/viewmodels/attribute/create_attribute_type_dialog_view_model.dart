import 'package:stocker/components/models/attribute_type.dart';
import 'package:stocker/components/viewmodels/attribute/attribute_view_model.dart';

class CreateAttributeTypeDialogViewModel extends AttributeViewModel {

  final AttributeType attributeType = AttributeType();

  CreateAttributeTypeDialogViewModel(store, userRef) : super(store, userRef);

  String validateName(String name) => (name?.isEmpty ?? true) ? 'O nome não pode ser vazio!' : null;

  void saveName(String name) => attributeType.name = name;

  Future<void> createNewAttributeType() =>
    userRef.collection('stores')
        .document(store.id)
        .collection('attribute_types')
        .document()
        .setData(this.attributeType.toJson());

}