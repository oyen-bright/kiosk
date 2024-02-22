import 'dart:io';
import 'dart:typed_data';

File convertUint8ListToFile(Uint8List data, String filePath) {
  final file = File(filePath);
  file.writeAsBytesSync(data);
  return file;
}
