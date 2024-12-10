class History {
  // Define class properties
  int? id; // id can be nullable
  int type;
  int amount;
  int date;
  int itemId;

  // Constructor with optional 'id' parameter
  History(this.type, this.amount, this.date, this.itemId, {this.id});

  // Convert a map to a History instance
  History.fromJson(Map<String, dynamic> map)
      : id = map['id'], // Nullable, so no default needed
        type = map['type'] ?? 0, // Default to 0 if null
        amount = map['amount'] ?? 0, // Default to 0 if null
        date = map['date'] ?? 0, // Default to 0 if null
        itemId = map['item_id'] ?? 0; // Default to 0 if null

  // Convert a History instance to a map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'date': date,
      'item_id': itemId,
    };
  }
}
