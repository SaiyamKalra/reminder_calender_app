class Event {
  final String title;
  final String description;
  final DateTime fromDate;
  // final DateTime toDate;
  final DateTime createdAt;

  const Event({
    required this.title,
    required this.description,
    required this.fromDate,
    // required this.toDate,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'fromDate': fromDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    title: json['title'] as String,
    description: json['description'] as String,
    fromDate: DateTime.parse(json['fromDate'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
