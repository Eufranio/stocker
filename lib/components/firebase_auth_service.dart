
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stocker/components/user.dart';

class FirebaseAuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _signIn = GoogleSignIn();

  bool isLoading = false;
  User user;
  
  Stream<User> get currentUser => _auth.onAuthStateChanged.map(_userFromFirebase);
  
  void checkCurrentUser() async {
    await _auth.currentUser();
  }

  Future<User> signInAnonymously() async {
    isLoading = true;
    this.notifyListeners();

    final authResult = await _auth.signInAnonymously();
    isLoading = false;
    this.notifyListeners();

    return this.user = _userFromFirebase(authResult.user);
  }

  Future<User> signInWithGoogle() async {
    this.isLoading = true;
    this.notifyListeners();

    final googleUser = await _signIn.signIn();
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final authResult = await _auth.signInWithCredential(credential);

    this.isLoading = false;
    this.user = _userFromFirebase(authResult.user);
    this.notifyListeners();

    return this.user;
  }

  Future<void> signOut() async {
    this.user = null;
    this.notifyListeners();
    return _auth.signOut();
  }

  User _userFromFirebase(FirebaseUser user) {
    if (user == null) {
      return null;
    }
    return User(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
    );
  }

}