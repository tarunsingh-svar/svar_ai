class TranscribeModel {
  final int id;
  final String? title;
  final String? transcribeText;
  final List<String>? tags;
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TranscribeModel({
    required this.id,
    required this.userId,
    required this.createdAt,
    this.title,
    this.transcribeText,
    this.tags,
    this.updatedAt,
  });

  factory TranscribeModel.fromJson(Map<String, dynamic> json) {
    return TranscribeModel(
      id: json['id'],
      title: json['title'],
      transcribeText: json['transcribe_text'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'transcribe_text': transcribeText,
    'tags': tags,
    'user_id': userId,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
