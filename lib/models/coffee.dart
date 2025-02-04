class Coffee {
  final String name;
  final String description;
  final double rating;
  final double price;
  final String image;
  final String category;

  Coffee({
    required this.name,
    required this.description,
    required this.rating,
    required this.price,
    required this.image,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'rating': rating,
    'price': price,
    'image': image,
    'category': category,
  };

  factory Coffee.fromJson(Map<String, dynamic> json) => Coffee(
    name: json['name'],
    description: json['description'],
    rating: json['rating'].toDouble(),
    price: json['price'].toDouble(),
    image: json['image'],
    category: json['category'],
  );
}
