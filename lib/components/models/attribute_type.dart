class AttributeType {

  String id, name;

  AttributeType(this.id, this.name);

  AttributeType.fromMap(String id, Map snapshot) :
      id = id,
      name = snapshot['name'];

  toJson() => {
    'name': name
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttributeType &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}