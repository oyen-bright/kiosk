import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<String> compressImage(File file, String targetPath) async {
  var result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 50,
    rotate: 0,
  );

  return result!.path;
}
