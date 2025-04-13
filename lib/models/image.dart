class DefibrillatorImage {
  final String url; 
  final String? id;

  DefibrillatorImage({
    required this.url,
    this.id,
  });

  factory DefibrillatorImage.fromJson(Map<String, dynamic> json) {
    return DefibrillatorImage(
      url: json['url'] as String,
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'id': id,
    };
  }
}
