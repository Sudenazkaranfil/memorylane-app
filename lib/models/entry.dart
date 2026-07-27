class Entry {
  final int id;
  final String? locationName;
  final double? lat;
  final double? lng;
  final String? textContent;
  final String? mood;
  final DateTime? date;
  final DateTime createdAt;
  final List<String> photoUrls;
  final String? canvasData;

  Entry({
    required this.id,
    this.locationName,
    this.lat,
    this.lng,
    this.textContent,
    this.mood,
    this.date,
    required this.createdAt,
    required this.photoUrls,
    this.canvasData,
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      id: json['id'],
      locationName: json['locationName'],
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      textContent: json['textContent'],
      mood: json['mood'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      photoUrls: json['photoUrls'] != null
          ? List<String>.from(json['photoUrls'])
          : [],
      canvasData: json['canvasData'],
    );
  }
}