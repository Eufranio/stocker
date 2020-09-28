
import 'package:flutter/material.dart';

class User {
  User({
    @required this.uid,
    this.email,
    this.photoUrl,
    this.displayName
  });

  String uid;
  String email;
  String photoUrl;
  String displayName;
}