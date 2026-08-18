class PlaceRecommendation {
  const PlaceRecommendation({required this.id, required this.name, required this.category, required this.rating, required this.priceLevel, required this.address, required this.score, required this.distanceMeters, required this.reason, required this.pros, required this.cons});

  final String id;
  final String name;
  final String category;
  final double rating;
  final int priceLevel;
  final String address;
  final double score;
  final int distanceMeters;
  final String reason;
  final List<String> pros;
  final List<String> cons;

  factory PlaceRecommendation.fromJson(Map<String, dynamic> json) {
    final place = json['place'] as Map<String, dynamic>;
    return PlaceRecommendation(
      id: place['id'] as String,
      name: place['name'] as String,
      category: place['category'] as String,
      rating: (place['rating'] as num).toDouble(),
      priceLevel: place['price_level'] as int,
      address: place['address'] as String,
      score: (json['score'] as num).toDouble(),
      distanceMeters: json['distance_meters'] as int,
      reason: json['reason'] as String,
      pros: List<String>.from(json['pros'] as List<dynamic>),
      cons: List<String>.from(json['cons'] as List<dynamic>),
    );
  }
}

