import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stocker/components/models/client.dart';
import 'package:stocker/components/models/receipt.dart';
import 'package:stocker/components/models/stock.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/route/routes.dart';
import 'package:stocker/screens/client/client_screen.dart';

class OrderHistoryScreen extends StatefulWidget {

  final Stock stock;
  final Store store;

  OrderHistoryScreen(this.store, this.stock);

  @override
  State createState() => _OrderHistoryScreenState();

}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {

  var _isSelected = [true, false, false];

  @override
  Widget build(BuildContext context) {
    var limitDate = _isSelected[0] ? DateTime.now().subtract(Duration(days: 15)) :
        _isSelected[1] ? DateTime.now().subtract(Duration(days: 30)) :
            DateTime(2020); // 01/01/2020
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico'),
      ),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text('Disponível'),
                      Text('${widget.stock.quantity} ${widget.stock.unity}',
                          style: TextStyle(fontSize: 35, color: Colors
                              .black45))
                    ],
                  ),
                  ToggleButtons(
                    constraints: BoxConstraints(minWidth: 60, minHeight: 32),
                    children: [
                      Text('15 dias'),
                      Text('30 dias'),
                      Text('Tudo')
                    ],
                    isSelected: _isSelected,
                    onPressed: (index) => setState(() {
                      _isSelected = [false, false, false];
                      _isSelected[index] = true;
                    }),
                  )
                ],
              )
            ),
            Divider(
              thickness: 10,
            ),
            Expanded(
              child: StreamBuilder(
                stream: context.watch<DocumentReference>()
                    .collection('stores')
                    .document(widget.store.id)
                    .collection('stocks')
                    .document(widget.stock.id)
                    .collection('receipts')
                    .orderBy('date', descending: true)
                    .where('date', isGreaterThan: limitDate)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    List<Receipt> list = snapshot.data.documents.map((e) => Receipt.fromMap(e.documentID, e.data)).toList();
                    return ListView.separated(
                      separatorBuilder: (_, __) => Divider(
                        color: Colors.purple,
                        indent: 70,
                      ),
                      itemCount: list.length,
                      itemBuilder: (context, index) => _buildListTile(context, list[index])
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                }
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, Receipt receipt) {
    var userRef = context.read<DocumentReference>();
    return FutureBuilder(
      future: receipt.client_id == null ? Future.value(true) : userRef.collection('stores')
          .document(widget.store.id)
          .collection('clients')
          .document(receipt.client_id)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var client;
          var text;
          var textStyle = TextStyle(fontSize: 16);
          if (snapshot.data != null && !(snapshot.data is bool)) {
            client = Client.fromMap(snapshot.data.documentID, snapshot.data.data);
            text = Text(
              '${client.name} (${client.city})\n${receipt.description}',
              style: textStyle,
            );
          } else {
            text = Text(receipt.description, style: textStyle);
          }

          return ListTile(
            title: Text('${receipt.amount} ${widget.stock.unity} - ${receipt.client_name}', style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18,
            )),
            subtitle: text,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dateCard(receipt.date),
                receipt.adding ?
                Icon(Icons.add, color: Colors.green,) :
                Icon(Icons.remove, color: Colors.red,)
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.purple),
              onPressed: () {
                showDialog(context: context, builder: (ctx) => AlertDialog(
                  title: Text('Tem certeza que deseja remover esse histórico?'),
                  actions: [
                    FlatButton(
                      child: Text('Fechar'),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    FlatButton(
                        child: Text('Remover'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Provider.of<DocumentReference>(ctx, listen: false)
                              .collection('stores')
                              .document(widget.store.id)
                              .collection('stocks')
                              .document(widget.stock.id)
                              .collection('receipts')
                              .document(receipt.id)
                              .delete().then((value) => Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('Histórico excluído!'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.purple,
                          )));
                        }
                    )
                  ],
                ));
              },
            ),
            onTap: client == null ? null : () => Navigator.pushNamed(context, Routes.client, arguments: [userRef, widget.store, client]),
          );
        }
        return Center(child: Text('Carregando...'),);
      }
    );
  }

  Widget _dateCard(DateTime date) {
    var day = DateFormat('EEE');
    var month = DateFormat('MMM');
    return Column(
      children: [
        Text(day.format(date).toUpperCase(), style: TextStyle(fontSize: 12)),
        Text(date.day.toString(), style: TextStyle(fontSize: 18)),
        Text(month.format(date).toUpperCase(), style: TextStyle(fontSize: 12))
      ],
    );
  }
}