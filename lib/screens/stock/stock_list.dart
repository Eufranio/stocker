import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stocker/components/models/stock.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/route/routes.dart';
import 'package:stocker/components/viewmodels/stock/stock_list_view_model.dart';
import 'package:stocker/components/widgets/product_display.dart';
import 'package:stocker/components/widgets/search_bar_wrapper.dart';
import 'package:stocker/components/widgets/stream_utils.dart';

class StockListScreen extends StatefulWidget {

  final StockListViewModel viewModel;

  StockListScreen(Store store, DocumentReference userRef)
      : viewModel = StockListViewModel(store, userRef);

  @override
  State createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estoques de ${widget.viewModel.store.name}'),
      ),
      body: Container(
        child: widget.viewModel.stocks.streamBuilder(_buildSearchBar),
      ),
    );
  }

  Widget _buildSearchBar(List<Stock> stocks) {
    return SearchBarWrapper<Stock>(stocks, widget.viewModel.search, _buildProduct);
  }

  Widget _buildProduct(Stock stock) {
    var userRef = context.read<DocumentReference>();
    return widget.viewModel.getProduct(stock).asStream().streamBuilder((product) => Row(
      children: [
        Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Text('Qtd', style: TextStyle(fontSize: 15, color: Colors.black54)),
                Text('${stock.quantity}', style: TextStyle(fontSize: 35, color: Colors.green)),
                Text(stock.unity, style: TextStyle(fontSize: 18, color: Colors.black54))
              ],
            )
        ),
        Expanded(
          child: ProductDisplay(
              widget.viewModel.store,
              product,
              height: 150,
              onPressed: () => Navigator.pushNamed(context, Routes.stock, arguments: [userRef, widget.viewModel.store, stock, product])
          ),
        )
      ],
    ), () => Container(height: 200, child: Center(child: CircularProgressIndicator())));
  }

}