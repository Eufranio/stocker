import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stocker/components/models/client.dart';
import 'package:stocker/components/models/product.dart';
import 'package:stocker/components/models/receipt.dart';
import 'package:stocker/components/models/stock.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/user.dart';
import 'package:stocker/components/widgets/product_display.dart';
import 'package:stocker/screens/order/pick_client_dialog.dart';

class SingleOrderScreen extends StatefulWidget {

  final Product product;
  final Store store;
  final Stock stock;

  SingleOrderScreen(this.product, this.store, this.stock);

  @override
  State createState() => _SingleOrderScreenState();

}

class _SingleOrderScreenState extends State<SingleOrderScreen> {

  var _isSelected = [true, false];
  var receipt = Receipt();
  Client selectedClient;

  @override
  Widget build(BuildContext context) {
    var key = GlobalKey<FormState>();

    var seller = TextFormField(
      decoration: InputDecoration(
        labelText: 'Vendedor',
      ),
      initialValue: context.watch<User>().displayName,
      onSaved: (val) {
        receipt.client_name = val;
      },
    );
    
    var client = TextFormField(
      enabled: selectedClient == null,
      initialValue: selectedClient != null ? ('${selectedClient.name} (${selectedClient.city})') : null,
      decoration: InputDecoration(
        labelText: 'Cliente',
      ),
      onTap: () {
        showDialog(context: context, builder: (_) => AlertDialog(
          contentPadding: EdgeInsets.all(5),
          insetPadding: EdgeInsets.all(15),
          title: Text('Selecionar cliente'),
          content: PickClientDialog(widget.store),
        )).then((value) => setState(() {
          this.selectedClient = value;
          this.receipt.client_id = value?.id;
        }));
      },
      onSaved: (val) {
        receipt.client_id = selectedClient.id;
      },
      validator: (_) {
        if (receipt.client_id == null)
          return 'Nenhum cliente selecionado!';
        return null;
      },
    );

    var description = TextFormField(
      decoration: InputDecoration(
        labelText: 'Descrição',
        labelStyle: TextStyle(color: Colors.purple),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.multiline,
      maxLines: 3,
      validator: (val) {
        if (val == null || val.isEmpty)
          return 'Adicione uma descrição!';
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onSaved: (val) {
        receipt.description = val;
      },
    );

    var quantity = TextFormField(
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Quantidade',
        labelStyle: TextStyle(color: Colors.purple),
        border: OutlineInputBorder(),
      ),
      validator: (str) {
        if (str == null || str.isEmpty)
          return 'Valor inválido!';
        int amount = int.parse(str);
        if (_isSelected[1]) { // removing
          if (amount > widget.stock.quantity)
            return 'Menor que estoque!';
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.always,
      onSaved: (val) {
        int amount = int.parse(val);
        receipt.amount = amount;
        if (_isSelected[0]) {
          widget.stock.quantity += amount;
          receipt.adding = true;
        } else {
          widget.stock.quantity -= amount;
          receipt.adding = false;
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar ${widget.product.name}'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () {
          if (key.currentState.validate()) {
            key.currentState.save();

            receipt.date = DateTime.now();

            var ref = context.read<DocumentReference>()
                .collection('stores')
                .document(widget.store.id)
                .collection('stocks')
                .document(widget.stock.id);
            ref.setData(widget.stock.toJson())
                .then((_) => ref.collection('receipts').document().setData(receipt.toJson()))
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
                        child: ProductDisplay(widget.store, widget.product),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          Text('${widget.stock.quantity}',
                              style: TextStyle(fontSize: 40, color: Colors
                                  .black45)),
                          Text(widget.stock.unity,
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
                                    onPressed: () {
                                      if (this.selectedClient != null) {
                                        setState(() {
                                          this.selectedClient = null;
                                          this.receipt.client_id = null;
                                        });
                                      }
                                    }
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
                                isSelected: _isSelected,
                                onPressed: (index) => _setState(() {
                                  bool previous = _isSelected[index];
                                  _isSelected = [false, false];
                                  _isSelected[index] = !previous;
                                }),
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
                                  child: Center(child: Text('${widget.stock.unity}',
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