class Journal {
  final int id;
  final String title;
  final String? coverImageUrl;
  final String visibility;
  final DateTime createdAt;
  final String? username;

  Journal({
    required this.id,
    required this.title,
    this.coverImageUrl,
    required this.visibility,
    required this.createdAt,
    this.username,
  });

  factory Journal.fromJson(Map<String, dynamic> json) {
    return Journal(
      id: json['id'],
      title: json['title'],
      coverImageUrl: json['coverImageUrl'],
      visibility: json['visibility'],
      createdAt: DateTime.parse(json['createdAt']),
      username: json['user']?['username'],
    );
  }
}