import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> saveThumbnail(File image) async {
  final directory = await getApplicationDocumentsDirectory();
  final thumbnailPath = '${directory.path}/thumbnails/${DateTime.now().millisecondsSinceEpoch}.png';
  final thumbnailFile = File(thumbnailPath);
  await thumbnailFile.writeAsBytes(await image.readAsBytes());
  return thumbnailPath;
}
