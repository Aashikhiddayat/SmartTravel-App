class Trip {
  const Trip({required this.id, required this.title, required this.destination, required this.startDate, required this.endDate, required this.budget, required this.currency, this.status = 'upcoming'});

  final String id;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final String currency;
  final String status;

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        id: json['id'] as String,
        title: json['title'] as String,
        destination: json['destination'] as String,
        startDate: DateTime.parse(json['start_date'] as String),
        endDate: DateTime.parse(json['end_date'] as String),
        budget: (json['budget'] as num).toDouble(),
        currency: json['currency'] as String? ?? 'INR',
        status: json['status'] as String? ?? 'upcoming',
      );

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'destination': destination, 'start_date': _date(startDate), 'end_date': _date(endDate), 'budget': budget, 'currency': currency, 'status': status};

  static String _date(DateTime date) => date.toIso8601String().split('T').first;
}

