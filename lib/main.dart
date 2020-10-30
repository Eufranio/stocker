import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stocker/components/firebase_auth_service.dart';
import 'package:stocker/components/user.dart';
import 'package:stocker/screens/home.dart';
import 'package:stocker/screens/login.dart';
import 'package:stocker/components/widgets/stream_utils.dart';

class Main {
  static FirebaseAuthService authService;
  static Stream<User> get userStream => authService.currentUser;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  var authService = FirebaseAuthService();
  Main.authService = authService;

  Intl.defaultLocale = 'pt_BR';
  initializeDateFormatting()
      .then((value) => authService.checkCurrentUser())
      .then((value) => runApp(MultiProvider(
    providers: [
      StreamProvider(create: (_) => authService.currentUser),
      ProxyProvider<User, DocumentReference>(
          update: (context, user, ref) => Firestore.instance.collection('users').document(user.uid)
      ),
      ChangeNotifierProvider.value(value: authService)
    ],
    child: MyApp(),
  )));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Montserrat',
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.purple,
          contentTextStyle: TextStyle(
            fontFamily: 'Montserrat',
            color: Colors.white
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20)))
        ),
        toggleButtonsTheme: ToggleButtonsThemeData(
          borderColor: Colors.purpleAccent,
          selectedBorderColor: Colors.purple,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          fillColor: Colors.purpleAccent,
          highlightColor: Colors.white,
          selectedColor: Colors.white,
        ),
        cardTheme: CardTheme(
            elevation: 6,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            clipBehavior: Clip.hardEdge,
          color: Colors.purpleAccent
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.purple),
          border: OutlineInputBorder(),
        )
      ),
      home: Consumer<User>(
        builder: (_, user, __) {
          return user == null ? LoginPage() : HomePage();
        },
      )
    );
  }
}
