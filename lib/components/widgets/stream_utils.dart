
import 'package:flutter/material.dart';

extension StreamBuilderExtension<T> on Stream<T> {
  Widget streamBuilder(Widget Function(T) innerWidget, [Widget Function() noDataWidget]) {
    return StreamBuilder<T>(
      stream: this,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (snapshot.hasData) {
          return Function.apply(innerWidget, [snapshot.data]);
        }
        return noDataWidget?.call() ?? Center(child: CircularProgressIndicator());
      },
    );
  }
}