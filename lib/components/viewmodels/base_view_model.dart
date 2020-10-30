import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseViewModel {

  final DocumentReference userRef;

  BaseViewModel(this.userRef);

  void dispose() {}

}