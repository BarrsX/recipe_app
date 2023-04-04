class Meal {
  final int id;
  final String title;
  final int readyInMinutes;
  final String? image;

  Meal({
    required this.id,
    required this.title,
    required this.readyInMinutes,
    required this.image,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      title: json['title'],
      readyInMinutes: json['readyInMinutes'],
      image: json['image'],
    );
  }
}
