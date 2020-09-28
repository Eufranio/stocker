class Receipt {

  String id, client_id, client_name, description;
  DateTime date;
  int amount;
  bool adding;

  Receipt({this.id, this.client_id, this.client_name, this.date, this.amount, this.adding});

  Receipt.fromMap(String id, Map snapshot) :
        id = id,
        client_id = snapshot['client_id'],
        client_name = snapshot['client_name'],
        description = snapshot['description'],
        date = snapshot['date'].toDate(),
        amount = snapshot['amount'],
        adding = snapshot['adding'];

  toJson() => {
    'client_id': client_id,
    'client_name': client_name,
    'description': description,
    'date': date,
    'amount': amount,
    'adding': adding
  };

}