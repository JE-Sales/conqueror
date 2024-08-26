class Scan {
  final int? id;
  final String thumbnailPath;
  final String textResult;
  final String dateTime;

  Scan({this.id, required this.thumbnailPath, required this.textResult, required this.dateTime});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'thumbnailPath': thumbnailPath,
      'textResult': textResult,
      'dateTime': dateTime,
    };
  }
}
