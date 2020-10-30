class ProductAttribute {

  String id, type, value;

  ProductAttribute([this.id, this.type, this.value]);

  ProductAttribute.fromMap(String id, Map snapshot) :
      id = id,
      type = snapshot['type'],
      value = snapshot['value'];

  toJson() => {
    'type': type,
    'value': value
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAttribute &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          value == other.value;

  @override
  int get hashCode => id.hashCode ^ type.hashCode ^ value.hashCode;
}