class Order {

  String id, seller, client;
  DateTime date;
  int total;
  Map<String, int> products;

  Order(this.id, this.seller, this.client, this.date, this.total, this.products);

  Order.fromMap(String id, Map snapshot) :
      id = id,
      seller = snapshot['seller'],
      client = snapshot['client'],
      date = DateTime.parse(snapshot['date']),
      total = snapshot['total'],
      products = snapshot['products'];

  toJson() => {
    'seller': seller,
    'client': client,
    'date': date.toIso8601String(),
    'total': total,
    'products': products
  };

}