class ProductMatch {
  int? id;
  String? title;
  String? description;
  String? price;
  String? imageUrl;
  double? averageRating;
  double? ratingCount;
  double? score;
  String? link;

  ProductMatch({
    this.id,
    this.title,
    this.description,
    this.price,
    this.imageUrl,
    this.averageRating,
    this.ratingCount,
    this.score,
    this.link,
  });

  factory ProductMatch.fromJson(Map<String, dynamic> json) => ProductMatch(
        id: json['id'] as int?,
        title: json['title'] as String?,
        description: json['description'] as String?,
        price: json['price'] as String?,
        imageUrl: json['imageUrl'] as String?,
        averageRating: (json['averageRating'] as num?)?.toDouble(),
        ratingCount: json['ratingCount'] as double?,
        score: (json['score'] as num?)?.toDouble(),
        link: json['link'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'averageRating': averageRating,
        'ratingCount': ratingCount,
        'score': score,
        'link': link,
      };
}
