class ItemModel {
  int? _id; // Private field for id
  String _name; // Private field for name
  String? _description; // Private field for description
  double _price; // Private field for price
  String? _category; // Private field for category
  int _stock; // Private field for stock
  String _image; // Private field for image

  // Constructor
  ItemModel(
      this._name,
      this._description,
      this._price,
      this._category,
      this._image,
      this._stock, {
        int? id,
      }) : _id = id;

  // Named constructor for JSON
  ItemModel.fromJson(Map<String, dynamic> map)
      : _id = map['id'],
        _name = map['name'],
        _description = map['description'],
        _price = map['price'],
        _category = map['category'],
        _image = map['image'],
        _stock = map['stock'];

  // Getter and setter for id
  int? get id => _id;
  set id(int? value) => _id = value;

  // Getter and setter for name
  String get name => _name;
  set name(String value) {
    if (value.isEmpty) {
      throw ArgumentError("Name cannot be empty.");
    }
    _name = value;
  }

  // Getter and setter for description
  String? get description => _description;
  set description(String? value) => _description = value;

  // Getter and setter for price
  double get price => _price;
  set price(double value) {
    if (value < 0) {
      throw ArgumentError("Price cannot be negative.");
    }
    _price = value;
  }

  // Getter and setter for category
  String? get category => _category;
  set category(String? value) => _category = value;

  // Getter and setter for stock
  int get stock => _stock;
  set stock(int value) {
    if (value < 0) {
      throw ArgumentError("Stock cannot be negative.");
    }
    _stock = value;
  }

  // Getter and setter for image
  String get image => _image;
  set image(String value) {
    if (value.isEmpty) {
      throw ArgumentError("Image path cannot be empty.");
    }
    _image = value;
  }

  // Method to convert an Item to a map
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'name': _name,
      'description': _description,
      'price': _price,
      'category': _category,
      'image': _image,
      'stock': _stock
    };
  }
}
