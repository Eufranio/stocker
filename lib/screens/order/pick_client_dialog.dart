import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stocker/components/models/client.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/widgets/cached_image.dart';

class PickClientDialog extends StatefulWidget {

  final Store store;

  PickClientDialog(this.store);

  @override
  State createState() => _PickClientDialog();

}

class _PickClientDialog extends State<PickClientDialog> {

  var clients = List<Client>();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
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
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: InkWell(
          onTap: () {
            Navigator.pop(context, client);
          },
          child: Card(
              color: Colors.purpleAccent,
              child: ListTile(
                contentPadding: EdgeInsets.all(10),
                leading: CachedImage(
                  imageUrl: client.image_url,
                  defaultImageHeight: 80,
                  width: 80,
                ),
                title: Text(
                  '${client.name} (${client.city})',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                subtitle: Text(
                    client.address,
                    style: TextStyle(fontSize: 14, color: Colors.white)
                ),
              )
          ),
        ),
    );
  }

}