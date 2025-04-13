class AedImage {
  final String url;
  final String? description;
  final DateTime? createdAt;

  AedImage({
    required this.url,
    this.description,
    this.createdAt,
  });

  factory AedImage.fromJson(Map<String, dynamic> json) {
    return AedImage(
      url: json['url'] as String,
      description: json['description'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
