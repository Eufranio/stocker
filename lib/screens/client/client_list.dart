import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stocker/components/models/client.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/widgets/cached_image.dart';
import 'package:stocker/screens/client/edit_client.dart';

import 'client_screen.dart';

class ClientListScreen extends StatefulWidget {

  final Store store;

  ClientListScreen(this.store);

  @override
  State createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {

  var clients = List<Client>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clientes de ${widget.store.name}'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => EditClientScreen(widget.store, Client(null, null, null, null, null, null))));
        },
      ),
      body: Container(
        child: StreamBuilder(
          stream: context.watch<DocumentReference>()
              .collection('stores')
              .document(widget.store.id)
              .collection('clients')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              this.clients = snapshot.data.documents.map((e) => Client.fromMap(e.documentID, e.data)).toList();
              return _buildSearchBar();
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: SearchBar<Client>(
          emptyWidget: Center(child: Text('Nada para mostrar', style: TextStyle(color: Colors.purple, fontSize: 25))),
          crossAxisCount: (MediaQuery.of(context).size.width / 300).floor(),
          hintText: 'Pesquisar',
          searchBarStyle: SearchBarStyle(
              padding: EdgeInsets.symmetric(horizontal: 10),
              borderRadius: BorderRadius.circular(30)
          ),
          onSearch: (str) {
            return Provider.of<DocumentReference>(context, listen: false)
                .collection('stores')
                .document(widget.store.id)
                .collection('clients')
                .getDocuments()
                .then((docs) => docs.documents.map((doc) => Client.fromMap(doc.documentID, doc.data)))
                .then((clients) => clients.where((client) => client.name.toLowerCase().contains(str.toLowerCase())).toList());
          },
          suggestions: clients,
          onItemFound: (client, index) => _buildClient(client),
        )
    );
  }

  Widget _buildClient(Client client) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ClientScreen(widget.store, client)));
      },
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                child: Card(
                  color: Colors.white38,
                  elevation: 5,
                  child: CachedImage(imageUrl: client.image_url, width: 100, defaultImageHeight: 100,),
                ),
              ),
              Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client.name, style: TextStyle(
                        fontSize: 22,
                        color: Colors.purple,
                      )),
                      Text(client.address, style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87
                      )),
                      Text(client.city, style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87
                      )),
                      Text(client.phone, style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87
                      )),
                    ],
                  )
              )
            ],
          ),
          Divider(thickness: 3, indent: 70,)
        ],
      ),
    );
  }
}