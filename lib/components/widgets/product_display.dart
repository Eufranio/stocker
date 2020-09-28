
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stocker/components/models/product.dart';
import 'package:stocker/components/models/product_attribute.dart';
import 'package:stocker/components/models/stock.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/widgets/attribute_text.dart';
import 'package:stocker/screens/stock/stock_screen.dart';

class ProductDisplay extends StatelessWidget {

  final Store store;
  final Product product;
  final Function onPressed;

  final double height;

  ProductDisplay(this.store, this.product, { this.onPressed, this.height });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: this.height,
      child: Card(
        color: Colors.white70,
        child: InkWell(
          onTap: onPressed,
          child: FutureBuilder(
              future: context.watch<DocumentReference>()
                  .collection('stores')
                  .document(store.id)
                  .collection('product_attributes')
                  .where(FieldPath.documentId, whereIn: product.attributes.isEmpty ? ['test'] : product.attributes)
                  .getDocuments(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      product.imageUrl != null ?
                      CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Icon(Icons.error)
                      ) : FlutterLogo(size: this.height),
                      Container(
                        width: double.infinity,
                        color: Colors.purple.withOpacity(0.6),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: AttributeText(store, product),
                        ),
                      )
                    ],
                  );
                }
                return Container(height: this.height, child: Center(child: CircularProgressIndicator()));
              }
          ),
        ),
      ),
    );
  }
}