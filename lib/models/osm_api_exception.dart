class OsmApiException implements Exception {
  final int statusCode;
  final String body;

  OsmApiException(this.statusCode, this.body);

  @override
  String toString() => 'OsmApiException($statusCode): $body';
}