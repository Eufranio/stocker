
class Stock {

  String id;
  int quantity;
  String unity;
  String product;

  Stock(this.id, this.quantity, this.unity, this.product);

  Stock.fromMap(String id, Map snapshot) :
      id = id,
      quantity = snapshot['quantity'],
      unity = snapshot['unity'],
      product = snapshot['product'];

  toJson() => {
    'quantity': quantity,
    'unity': unity,
    'product': product
  };

}