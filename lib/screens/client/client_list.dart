import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:stocker/components/models/client.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/route/routes.dart';
import 'package:stocker/components/viewmodels/client/client_list_view_model.dart';
import 'package:stocker/components/widgets/cached_image.dart';
import 'package:stocker/components/widgets/stream_utils.dart';

class ClientListScreen extends StatefulWidget {

  final ClientListViewModel viewModel;

  ClientListScreen(Store store, DocumentReference userRef) : viewModel = ClientListViewModel(store, userRef);

  @override
  State createState() => _ClientListScreenState();

}

class _ClientListScreenState extends State<ClientListScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.viewModel.appBarTitle),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, Routes.clientEdit, arguments: [widget.viewModel.userRef, widget.viewModel.store, Client()])
      ),
      body: Container(
        child: widget.viewModel.clients.streamBuilder(_buildSearchBar),
      ),
    );
  }

  Widget _buildSearchBar(List<Client> clients) {
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
          onSearch: widget.viewModel.search,
          suggestions: clients,
          onItemFound: (client, index) => _buildClient(client),
        )
    );
  }

  Widget _buildClient(Client client) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, Routes.client, arguments: [widget.viewModel.userRef, widget.viewModel.store, client]),
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