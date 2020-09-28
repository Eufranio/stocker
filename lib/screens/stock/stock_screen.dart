
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';
import 'package:stocker/components/models/attribute_type.dart';
import 'package:stocker/components/models/product.dart';
import 'package:stocker/components/models/product_attribute.dart';
import 'package:stocker/components/models/stock.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/widgets/attribute_list.dart';
import 'package:stocker/components/widgets/product_display.dart';
import 'package:stocker/screens/order/order_history.dart';
import 'package:stocker/screens/order/single_order.dart';
import 'package:stocker/screens/product/product_screen.dart';


class StockScreen extends StatefulWidget {

  StockScreen(this.stock, this.product, this.store);

  Stock stock;
  Product product;
  Store store;

  @override
  State createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {

  var _menu = [true, false];
  
  @override
  Widget build(BuildContext context) {
    var controller = PreloadPageController();
    return Scaffold(
      appBar: AppBar(
        title: Text('Estoque de ${widget.product.name}'),
        actions: [
          PopupMenuButton(
            child: Padding(padding: EdgeInsets.only(right: 15), child: Icon(Icons.more_vert)),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Text('Excluir'),
              )
            ],
            onSelected: (val) {
              if (val == 1)
                _showDeleteStockDialog(context);
            },
          )
        ],
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(padding: EdgeInsets.symmetric(horizontal: 30), child: Container(
                constraints: BoxConstraints.loose(Size(300, 300)),
                child: ProductDisplay(widget.store, widget.product),
              )),
              Padding(
                padding: EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Disponível: ${widget.stock.quantity} ${widget.stock.unity}',
                      style: TextStyle(fontSize: 25, color: Colors.black45),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StatefulBuilder(
                  builder: (context, _setState) => Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: LayoutBuilder(builder: (context, constraints) => ToggleButtons(
                            constraints: BoxConstraints.expand(width: (constraints.maxWidth / 2) - 10, height: 40),
                            children: [
                              Text('Atributos'),
                              Text('Notas')
                            ],
                            isSelected: _menu,
                            onPressed: (index) => _setState(() {
                              _menu = [false, false];
                              _menu[index] = true;
                              controller.animateToPage(_menu.indexOf(true), duration: Duration(milliseconds: 200), curve: Curves.linear);
                            }),
                          ))
                      ),
                      Expanded(
                          child: PreloadPageView(
                            controller: controller,
                            preloadPagesCount: 2,
                            children: [
                              _buildAttributeMenu(context),
                              _buildNotesMenu(context)
                            ],
                          )
                      )
                    ],
                  ),
                )
              )
            ],
          ),
        )
      ),
    );
  }

  Widget _buildAttributeMenu(BuildContext context) {
    return Stack(
      children: [
        AttributeList(widget.store, widget.product),
        Positioned(
          bottom: 10, right: 10,
          child: FloatingActionButton(
            child: Icon(Icons.search),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductScreen(widget.product, widget.store)))
              .then((value) => setState(() {})),
          ),
        )
      ],
    );
  }

  Widget _buildNotesMenu(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: _buildCard(context,
            icon: Icon(Icons.history, color: Colors.white),
            title: Text('Histórico do produto', style: TextStyle(color: Colors.white, fontSize: 20)),
            trailing: PopupMenuButton(
              icon: Icon(Icons.more_vert, color: Colors.white),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  child: Text('Excluir'),
                ),
              ],
              onSelected: (index) {
                setState(() {});
              },
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => OrderHistoryScreen(widget.stock, widget.store)));
            }
          )
        ),
        ListTile(
            title: _buildCard(context,
                icon: Icon(Icons.create_new_folder, color: Colors.white),
                title: Text('Nova nota', style: TextStyle(color: Colors.white, fontSize: 20)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SingleOrderScreen(widget.product, widget.store, widget.stock)))
                    .then((value) => setState(() {}));
                },
                trailing: PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      child: Text('Excluir'),
                    ),
                  ],
                  onSelected: (index) {
                    setState(() {});
                  },
                )
            )
        ),
        ListTile(
            title: _buildCard(context,
                icon: Icon(Icons.edit, color: Colors.white),
                title: Text('Editar unidade', style: TextStyle(color: Colors.white, fontSize: 20)),
                onTap: () => _showEditUnitDialog(context),
                trailing: PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      child: Text('Excluir'),
                    ),
                  ],
                  onSelected: (index) {
                    setState(() {});
                  },
                )
            )
        )
      ],
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

  void _showEditUnitDialog(BuildContext context) {
    var key = GlobalKey<FormState>();
    showDialog(context: context, child: AlertDialog(
      title: Text('Editar unidade'),
      content: Form(
          key: key,
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Nova unidade',
              labelStyle: TextStyle(color: Colors.purple),
            ),
            autofocus: true,
            validator: (val) => val == null || val.isEmpty ? 'A unidade não pode ser vazia!' : null,
            onSaved: (val) {
              widget.stock.unity = val;;
            },
          )
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            if (key.currentState.validate()) {
              key.currentState.save();
              context.read<DocumentReference>()
                  .collection('stores')
                  .document(widget.store.id)
                  .collection('stocks')
                  .document(widget.stock.id)
                  .setData(widget.stock.toJson());
              Navigator.of(context).pop();
            }
          },
          child: Text('Salvar'),
        ),
      ],
    )).then((value) => setState(() {}));
  }

  _showDeleteStockDialog(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text('Tem certeza que deseja excluir esse estoque?'),
      actions: [
        FlatButton(
          child: Text('Excluir'),
          onPressed: () {

          }
        ),
        FlatButton(
          child: Text('Fechar'),
          onPressed: () {
            Navigator.pop(context);
          }
        )
      ],
    ));
  }

}