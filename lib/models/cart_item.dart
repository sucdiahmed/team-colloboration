class CartItem {
  final String name;
  final String image;
  final double price;
  int quantity;

  CartItem({
    required this.name,
    required this.image,
    required this.price,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'image': image,
    'price': price,
    'quantity': quantity,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    name: json['name'],
    image: json['image'],
    price: json['price'].toDouble(),
    quantity: json['quantity'],
  );
}
