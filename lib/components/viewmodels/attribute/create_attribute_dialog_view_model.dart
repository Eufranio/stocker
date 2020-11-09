import 'package:stocker/components/models/product_attribute.dart';
import 'package:stocker/components/viewmodels/attribute/attribute_list_view_model.dart';

class CreateAttributeDialogViewModel extends AttributeViewModel {

  final ProductAttribute productAttribute = ProductAttribute();

  CreateAttributeDialogViewModel(store, userRef) : super(userRef, store);

  String validateValue(String value) => (value?.isEmpty ?? true) ? 'O valor não pode ser vazio!' : null;

  void saveValue(String value) => productAttribute.value = value;

  Future<void> createNewAttribute() =>
      userRef.collection('stores')
          .document(store.id)
          .collection('product_attributes')
          .document()
          .setData(productAttribute.toJson());

}