
class Client {

  String id, name, address, city, phone, image_url;

  Client([this.id, this.name, this.address, this.city, this.phone, this.image_url]);

  Client.fromMap(String id, Map snapshot) :
      id = id,
      name = snapshot['name'],
      address = snapshot['address'],
      city = snapshot['city'],
      phone = snapshot['phone'],
      image_url = snapshot['image_url'];

  toJson() => {
    'name': name,
    'address': address,
    'city': city,
    'phone': phone,
    'image_url': image_url
  };

}