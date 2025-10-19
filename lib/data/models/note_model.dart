class NoteModel {
  final String title;
  final String subtitle;
  final String date;
  final String category;

  NoteModel({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.category,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
    title: json['title'],
    subtitle: json['subtitle'],
    date: json['date'],
    category: json['category'],
  );
}
