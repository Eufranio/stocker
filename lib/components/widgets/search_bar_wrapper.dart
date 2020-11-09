import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';

class SearchBarWrapper<T> extends StatelessWidget {

  final List<T> items;
  final Future<List<T>> Function(String) search;
  final Widget Function(T) buildItem;

  SearchBarWrapper(this.items, this.search, this.buildItem);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: SearchBar<T>(
        emptyWidget: Center(child: Text('Nada para mostrar', style: TextStyle(color: Colors.purple, fontSize: 25))),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        crossAxisCount: (MediaQuery.of(context).size.width / 200).floor(),
        hintText: 'Pesquisar',
        searchBarStyle: SearchBarStyle(
            padding: EdgeInsets.symmetric(horizontal: 10),
            borderRadius: BorderRadius.circular(30)
        ),
        onSearch: this.search,
        onItemFound: (item, index) => this.buildItem(item),
        suggestions: items,
      ),
    );
  }

}