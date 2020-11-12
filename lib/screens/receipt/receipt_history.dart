import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stocker/components/models/client.dart';
import 'package:stocker/components/models/product.dart';
import 'package:stocker/components/models/receipt.dart';
import 'package:stocker/components/models/stock.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/route/routes.dart';
import 'package:stocker/components/viewmodels/receipt/receipt_history_view_model.dart';
import 'package:stocker/components/widgets/stream_utils.dart';

class ReceiptHistoryScreen extends StatefulWidget {

  final ReceiptHistoryViewModel viewModel;

  ReceiptHistoryScreen(
      Store store,
      Stock stock,
      Product product,
      DocumentReference userRef)
      : viewModel = ReceiptHistoryViewModel(store, stock, product, userRef);

  @override
  State createState() => _ReceiptHistoryScreenState();
}

class _ReceiptHistoryScreenState extends State<ReceiptHistoryScreen> {

  @override
  Widget build(BuildContext context) {
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
                      Text(widget.viewModel.amountAvailable, style: TextStyle(fontSize: 35, color: Colors.black45))
                    ],
                  ),
                  ToggleButtons(
                    constraints: BoxConstraints(minWidth: 60, minHeight: 32),
                    children: [
                      Text('15 dias'),
                      Text('30 dias'),
                      Text('Tudo')
                    ],
                    isSelected: widget.viewModel.buttons,
                    onPressed: (index) => setState(() => widget.viewModel.selectButton(index)),
                  )
                ],
              )
            ),
            Divider(
              thickness: 10,
            ),
            Expanded(
              child: widget.viewModel.receipts.streamBuilder((receipts) => ListView.separated(
                  separatorBuilder: (_, __) => Divider(color: Colors.purple, indent: 70),
                  itemCount: receipts.length,
                  itemBuilder: (context, index) => _buildListTile(context, receipts[index])
              )),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, Receipt receipt) {
    return widget.viewModel.getReceiptClient(receipt).streamBuilder((val) {
      return ListTile(
        title: Text('${receipt.amount} ${widget.viewModel.stock.unity} - ${receipt.client_name}', style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 18,
        )),
        subtitle: Text(
            val is Client ? '${val.name} (${val.city})\n${receipt.description}' : receipt.description,
          style: TextStyle(fontSize: 16),
        ),
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
                    onPressed: () => widget.viewModel.deleteReceipt(receipt)
                    .then((_) => Navigator.pop(ctx))
                    .then((_) => Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Histórico excluído!'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.purple,
                    )))
                )
              ],
            ));
          },
        ),
        onTap: val is Client ? () => Navigator.pushNamed(context, Routes.client, arguments: [widget.viewModel.userRef, widget.viewModel.store, val]) : null,
      );
    });
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