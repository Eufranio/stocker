class Store {

  String id, name;
  List<String> products, clients;

  Store(this.id, this.name, this.products, this.clients);

  Store.fromMap(String id, Map snapshot) :
      id = id,
      name = snapshot['name'],
      products = List.from(snapshot['products']),
      clients = List.from(snapshot['clients']);

  toJson() => {
    'name': name,
    'products': products,
    'clients': clients
  };

}