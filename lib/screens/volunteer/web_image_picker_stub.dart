// Stub for non-web platforms, now redirects to unified file_helper
import 'dart:typed_data';
import '../../utils/file_helper.dart' as helper;

export '../../utils/file_helper.dart' show PickedImage;

Future<helper.PickedImage?> pickWebImage() async {
  return helper.pickImageFromDevice();
}

void downloadFileWeb(Uint8List bytes, String fileName) {
  helper.saveAndDownloadFile(bytes, fileName);
}
