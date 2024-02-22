class Categories {
  final int id;
  final String category;
  final String image;

  const Categories({
    required this.id,
    required this.category,
    required this.image,
  });

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      id: json["id"],
      category: json["category"],
      image: json['image'] ?? null.toString(),
    );
  }
  Map<String, dynamic> toJson() => {
        "id": id,
        "category": category,
        "image": image,
      };
}
