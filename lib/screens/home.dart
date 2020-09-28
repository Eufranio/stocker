import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stocker/components/firebase_auth_service.dart';
import 'package:stocker/components/user.dart';
import 'package:stocker/screens/store/store_list.dart';

class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    User user = context.watch<User>();

    var accountButton = RaisedButton.icon(
      icon: Icon(Icons.account_circle),
      label: Text('Conta', style: TextStyle(fontSize: 20)),
      color: Colors.white,
      onPressed: () {},
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      ),
    );

    var storeButton = RaisedButton.icon(
      icon: Icon(Icons.store),
      label: Text('Lojas', style: TextStyle(fontSize: 20)),
      color: Colors.white,
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => StoreListScreen())),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Stocker'),
        leading: IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              context.read<FirebaseAuthService>().signOut();
            }
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.purple, Colors.deepPurple]
            )
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Bem vindo(a)', style: TextStyle(fontSize: 20, color: Colors.white)),
              Text(user.displayName, style: TextStyle(fontSize: 30, color: Colors.white)),
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    accountButton,
                    SizedBox.fromSize(size: Size.square(30)),
                    storeButton,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}