class Product {

  String id, name, imageUrl;
  List<String> attributes;

  Product(this.id, this.name, this.imageUrl, this.attributes);

  Product.fromMap(String id, Map snapshot) :
      id = id,
      name = snapshot['name'],
      imageUrl = snapshot['imageUrl'],
      attributes = List.from(snapshot['attributes']);

  toJson() => {
    'name': name,
    'imageUrl': imageUrl,
    'attributes': attributes
  };

}