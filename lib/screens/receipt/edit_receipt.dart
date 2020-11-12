import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stocker/components/models/product.dart';
import 'package:stocker/components/models/receipt.dart';
import 'package:stocker/components/models/stock.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/user.dart';
import 'package:stocker/components/viewmodels/receipt/edit_receipt_view_model.dart';
import 'package:stocker/components/widgets/product_display.dart';
import 'package:stocker/screens/order/pick_client_dialog.dart';

class EditStockReceiptScreen extends StatefulWidget {

  final EditReceiptViewModel viewModel;

  EditStockReceiptScreen(
      Store store,
      Stock stock,
      Product product,
      Receipt receipt,
      DocumentReference userRef)
      : viewModel = EditReceiptViewModel(receipt, stock, product, store, userRef);

  @override
  State createState() => _EditStockReceiptScreenState();

}

class _EditStockReceiptScreenState extends State<EditStockReceiptScreen> {

  @override
  Widget build(BuildContext context) {
    var key = GlobalKey<FormState>();

    var seller = TextFormField(
      decoration: InputDecoration(
        labelText: 'Vendedor',
      ),
      initialValue: context.watch<User>().displayName,
      autovalidate: true,
      validator: widget.viewModel.validateField,
      onSaved: widget.viewModel.saveReceiptSeller,
    );
    
    var client = TextFormField(
      enabled: widget.viewModel.isClientFieldEnabled,
      initialValue: widget.viewModel.selectedClientName,
      decoration: InputDecoration(
        labelText: 'Cliente',
      ),
      onTap: () {
        showDialog(context: context, builder: (_) => AlertDialog(
          contentPadding: EdgeInsets.all(5),
          insetPadding: EdgeInsets.all(15),
          title: Text('Selecionar cliente'),
          content: PickClientDialog(widget.viewModel.store),
        )).then((client) => setState(() => widget.viewModel.selectClient(client)));
      },
      onSaved: (_) => widget.viewModel.saveClientId(),
      validator: (_) => widget.viewModel.validateClient(),
    );

    var description = TextFormField(
      decoration: InputDecoration(
        labelText: 'Descrição',
        labelStyle: TextStyle(color: Colors.purple),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.multiline,
      maxLines: 3,
      validator: widget.viewModel.validateField,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onSaved: widget.viewModel.saveReceiptDescription,
    );

    var quantity = TextFormField(
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Quantidade',
        labelStyle: TextStyle(color: Colors.purple),
        border: OutlineInputBorder(),
      ),
      validator: widget.viewModel.validateQuantity,
      autovalidateMode: AutovalidateMode.always,
      onSaved: widget.viewModel.saveQuantity,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar ${widget.viewModel.product.name}'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () {
          if (key.currentState.validate()) {
            key.currentState.save();
            widget.viewModel.saveReceipt()
                .then((_) => Navigator.pop(context));
          }
        },
      ),
      body: Container(
        child: Form(
            key: key,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 300,
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: ProductDisplay(widget.viewModel.store, widget.viewModel.product),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          Text('${widget.viewModel.stock.quantity}',
                              style: TextStyle(fontSize: 40, color: Colors
                                  .black45)),
                          Text(widget.viewModel.stock.unity,
                              style: TextStyle(fontSize: 25, color: Colors
                                  .black45))
                        ],
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Padding(padding: EdgeInsets.fromLTRB(35, 5, 35, 20), child: seller),
                      Padding(padding: EdgeInsets.fromLTRB(35, 0, 35, 20), child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(child: client),
                          Padding(
                            padding: EdgeInsets.only(left: 15),
                            child: ClipOval(
                              child: Container(
                                color: Colors.purple,
                                child: IconButton(
                                    icon: Icon(Icons.close, color: Colors.white),
                                    onPressed: () => setState(widget.viewModel.resetClient)
                                ),
                              ),
                            )
                          )
                        ],
                      )),
                      Padding(padding: EdgeInsets.fromLTRB(35, 0, 35, 20), child: description),
                      StatefulBuilder(
                          builder: (context, _setState) => Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Padding(
                              padding: EdgeInsets.fromLTRB(35, 5, 0, 20),
                              child: ToggleButtons(
                                children: [
                                  Icon(Icons.add),
                                  Icon(Icons.remove)
                                ],
                                isSelected: widget.viewModel.buttons,
                                onPressed: (index) => _setState(() => widget.viewModel.pushButton(index)),
                                borderColor: Colors.purpleAccent,
                                selectedBorderColor: Colors.purple,
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                fillColor: Colors.purpleAccent,
                                highlightColor: Colors.white,
                                selectedColor: Colors.white,
                              ),
                            ),
                              Expanded(child: Padding(
                                  padding: EdgeInsets.fromLTRB(25, 0, 25, 20),
                                  child: quantity)),
                              Padding(padding: EdgeInsets.only(right: 35, bottom: 20, top: 10),
                                  child: Center(child: Text('${widget.viewModel.stock.unity}',
                                    style: TextStyle(
                                        fontSize: 30,
                                        color: Colors.purple
                                    ),
                                    textAlign: TextAlign.center,
                                  ))),
                            ],
                          )
                      ),
                    ],
                  ),
                )
              ],
            )
        ),
      ),
    );
  }
}