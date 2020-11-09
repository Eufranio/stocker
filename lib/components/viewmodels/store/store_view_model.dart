import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/viewmodels/base_view_model.dart';

class StoreViewModel extends BaseViewModel {

  final Store store;

  StoreViewModel(this.store, userRef) : super(userRef);

}