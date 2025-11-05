class TranscribeModel {
  final int id;
  final String? transcribeText;
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TranscribeModel({
    required this.id,
    required this.transcribeText,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
  });

  factory TranscribeModel.fromJson(Map<String, dynamic> json) {
    return TranscribeModel(
      id: json['id'],
      transcribeText: json['transcribe_text'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'transcribe_text': transcribeText,
    'user_id': userId,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
