import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stocker/components/models/client.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/route/routes.dart';
import 'package:stocker/components/viewmodels/client/client_view_model.dart';
import 'package:stocker/components/widgets/cached_image.dart';

class ClientScreen extends StatefulWidget {

  final ClientViewModel viewModel;

  ClientScreen(Store store, Client client, DocumentReference userRef) :
        viewModel = ClientViewModel(client, store, userRef);

  @override
  State createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.viewModel.client.name),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () => Navigator.pushNamed(context, Routes.clientEdit, arguments: [
          widget.viewModel.userRef, widget.viewModel.store, widget.viewModel.client
        ]).then((value) => setState(() {}))
      ),
      body: Container(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                children: [
                  _buildCard(
                    context,
                    icon: Icon(Icons.create, color: Colors.white),
                    title: Text(widget.viewModel.client.name, style: TextStyle(fontSize: 20, color: Colors.white)),
                    subtitle: Text('Nome', style: TextStyle(color: Colors.white))
                  ),
                  _buildCard(
                      context,
                      icon: Icon(Icons.home, color: Colors.white),
                      title: Text(widget.viewModel.client.address, style: TextStyle(fontSize: 20, color: Colors.white)),
                      subtitle: Text('Endereço', style: TextStyle(color: Colors.white))
                  ),
                  _buildCard(
                      context,
                      icon: Icon(Icons.home_work_outlined, color: Colors.white),
                      title: Text(widget.viewModel.client.city, style: TextStyle(fontSize: 20, color: Colors.white)),
                      subtitle: Text('Cidade', style: TextStyle(color: Colors.white))
                  ),
                  _buildCard(
                      context,
                      icon: Icon(Icons.phone, color: Colors.white),
                      title: Text(widget.viewModel.client.phone, style: TextStyle(fontSize: 20, color: Colors.white)),
                      subtitle: Text('Telefone', style: TextStyle(color: Colors.white))
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Row(
          children: [
            SizedBox(
              width: 180,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Card(
                  color: Colors.white38,
                  elevation: 10,
                  child: CachedImage(imageUrl: widget.viewModel.client.image_url),
                ),
              ),
            ),
            Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.viewModel.client.name, style: TextStyle(
                      fontSize: 22,
                      color: Colors.purple,
                    )),
                    Text(widget.viewModel.client.address, style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87
                    )),
                    Text(widget.viewModel.client.city, style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87
                    )),
                    Text(widget.viewModel.client.phone, style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87
                    )),
                  ],
                )
            )
          ],
        ),
        Positioned(
          bottom: 10, right: 10,
          child: ClipOval(
            child: Container(
              color: Colors.purple,
              child: IconButton(
                icon: Icon(Icons.call, color: Colors.white),
                onPressed: () {},
              ),
            ),
          ),
        )
      ],
    );
  }
  
  Widget _buildImage(BuildContext context) {
    return Card(
      child: InkWell(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            CachedImage(imageUrl: widget.viewModel.client.image_url),
            Container(
              color: Colors.purple.withOpacity(0.6),
              width: double.maxFinite,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  '${widget.viewModel.client.name} (${widget.viewModel.client.city})',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget _buildCard(BuildContext context, {
    Widget icon,
    Widget title,
    Widget subtitle,
    Widget trailing,
    Function onTap
  }) {
    return Padding(
        padding: EdgeInsets.only(left: 8, right: 8, top: 15),
        child: InkWell(
          onTap: onTap,
          child: Card(
            child: ListTile(
              leading: icon,
              contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
              title: title,
              subtitle: subtitle,
              trailing: trailing,
            ),
          ),
        )
    );
  }

}